from fileinput import filename
import json
import re 
import os
import secrets
import base64
# import pywintypes
import getpass
# import win32wnet as wNet
# import win32netcon as wCon

from flask import Flask, config, jsonify, Response, request, render_template
from sqlalchemy.sql.expression import false, true
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy import engine, or_
from datetime import datetime
from waitress import serve

from settings import app, db, customAuthorization, loginAuthorization, syncStatus, db_raw
from models import Application, User, Company, Partner, Customer, Interest, Event, Submission, SubmissionStage, Notification, PNDealer, PNDealerBranch, PNCMO, Brand, Master, Category, SubmissionDetail, HREmployee
from tools import send_ocr_data

PAGINATE_LIST = 15


@app.route('/v1/app_config/', methods=['GET'])
def app_config():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401
    return jsonify(auth.serialize()), 200

@app.route('/v1/token/', methods=['POST'])
def token():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    phone = request.form.get('phone') or ''
    password = request.form.get('password') or ''

    if phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400
    elif password == '':
        return jsonify({"message":"Make sure your password must be filled"}), 400
    elif len(password) < 8:
        return jsonify({"message":"Make sure your password is at lest 8 letters"}), 400
    elif not re.search('[0-9]', password):
        return jsonify({"message":"Make sure your password has a number in it"}), 400
    elif not re.search('[A-Z]', password): 
        return jsonify({"message":"Make sure your password has a capital letter in it"}), 400

    user = User.query.filter_by(phone=phone).first()
    if not user:
        return jsonify({"message":"Phone number is not registered"}), 400
    elif not user.check_password(password):
        return jsonify({"message":"Password does not match, please try again"}), 400
    elif not user.partner: #Only partner can login this app
        return jsonify({"message":"Account not register on this app"}), 400
    else:
        if not user.is_active:
            return jsonify({"message":"Please activate your account, Contact Admin MACF!"}), 400
    
        checking_status = syncStatus("Partner "+str(user.partner.id))
        user.generate_token(auth)
        return jsonify(user.login_serialize()), 200

@app.route('/v1/signout/', methods=['GET'])
def signout():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    #Logout Token From User
    auth.signout_token()

    return jsonify({"message":"Account has been logout"}), 200

@app.route('/v1/signup/', methods=['POST'])
def signup():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    email = request.form.get('email') or ''
    phone = request.form.get('phone') or ''
    password = request.form.get('password') or ''
    activated = request.form.get('activated') or 0

    name = request.form.get('name') or ''
    company = request.form.get('company') or ''
    address = request.form.get('address') or ''
    latlng = request.form.get('latlng') or ''

    email_validate = '^[a-z0-9]+[\._]?[a-z0-9]+[@]\w+[.]\w{2,3}$'

    if email == '':
        return jsonify({"message":"Make sure your email must be filled"}), 400
    elif not re.search(email_validate, email):
        return jsonify({"message":"Make sure your email is valid"}), 400
    elif phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400
    elif password == '':
        return jsonify({"message":"Make sure your password must be filled"}), 400
    elif len(password) < 8:
        return jsonify({"message":"Make sure your password is at lest 8 letters"}), 400
    elif not re.search('[0-9]', password):
        return jsonify({"message":"Make sure your password has a number in it"}), 400
    elif not re.search('[A-Z]', password): 
        return jsonify({"message":"Make sure your password has a capital letter in it"}), 400

    if company != '':
        if name == '':
            return jsonify({"message":"Make sure your name must be filled"}), 400            
        elif address == '':
            return jsonify({"message":"Make sure your address must be filled"}), 400

    check_phone = User.query.filter_by(phone=phone).first() # if this returns a user, then the phone number already exists in database
    check_email = User.query.filter_by(email=email).first() # if this returns a user, then the email already exists in database

    if check_phone: # if a user is found, we want to give error response
        return jsonify({"message":"Phone Number %r has been registered" % phone}), 400
    elif check_email: # if a user is found, we want to give error response
        return jsonify({"message":"Email %r has been registered" % email}), 400

    # create a new user with the form data. Hash the password so the plaintext version isn't saved.
    new_user = User(email=email, phone=phone, password=generate_password_hash(password, method='sha256'), is_active=activated)
    # add the new user to the database
    db.session.add(new_user)

    # create Partner when company not null
    if company != '':
        company_formated = "%{}%".format(company)
        check_company = Company.query.filter(Company.name.like(company_formated)).first()
        if not check_company:
            code = "SMS/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Company.query.count())
            check_company = Company(code=code, name=company, address=address, latlng=latlng, is_active=1)
            db.session.add(check_company)
            db.session.commit()

        partner = Partner(name=name, company_id=check_company.id, user_id=new_user.id)
        db.session.add(partner)
    db.session.commit()

    return jsonify(new_user.serialize()), 200

@app.route('/v1/forgot_password/', methods=['POST'])
def forgot_password():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    phone = request.form.get('phone') or ''

    if phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400

    check_phone = User.query.filter_by(phone=phone).first() # if this returns a user, then the phone number already exists in database

    if not check_phone: # if a user is found, we want to give error response
        return jsonify({"message":"Phone Number %r not registered" % phone}), 400

    #Generate SMS Registration Token
    check_phone.generate_sms_forgot_password_token()

    return jsonify({"message":"OTP telah dikirim"}), 200

@app.route('/v1/forgot_password/verified/', methods=['POST'])
def verified_forgot_token():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    phone = request.form.get('phone') or ''
    token = request.form.get('token') or ''

    if phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400

    check_phone = User.query.filter_by(phone=phone).first() # if this returns a user, then the phone number already exists in database

    if not check_phone: # if a user is found, we want to give error response
        return jsonify({"message":"Phone Number %r not registered" % phone}), 400
    elif not check_phone.check_forgot_token(token):
        return jsonify({"message":"OTP code not match, please check OTP code"}), 400
    elif not check_phone.check_forgot_token_time(token):
        return jsonify({"message":"OTP code is expired"}), 400

    check_phone.success_check_forgot_token()

    return jsonify({"message":"OTP berhasil diverifikasi"}), 200

@app.route('/v1/new_password/', methods=['POST'])
def new_password_setup():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    phone = request.form.get('phone') or ''
    password = request.form.get('password') or ''

    if phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400
    elif password == '':
        return jsonify({"message":"Make sure your password must be filled"}), 400            

    check_phone = User.query.filter_by(phone=phone).first() # if this returns a user, then the phone number already exists in database

    if not check_phone: # if a user is found, we want to give error response
        return jsonify({"message":"Phone Number %r not registered" % phone}), 400

    check_phone.password = generate_password_hash(password, method='sha256')

    db.session.commit()

    return jsonify({"message":"OTP berhasil diverifikasi"}), 200

@app.route('/v1/join/', methods=['POST'])
def join():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    name = request.json.get('name') or ''
    email = request.json.get('email') or ''
    phone = request.json.get('phone') or ''

    email_validate = '^[a-z0-9]+[\._]?[a-z0-9]+[@]\w+[.]\w{2,3}$'

    if name == '':
        return jsonify({"message":"Make sure your name must be filled"}), 400
    elif email == '':
        return jsonify({"message":"Make sure your email must be filled"}), 400
    elif not re.search(email_validate, email):
        return jsonify({"message":"Make sure your email is valid"}), 400
    elif phone == '':
        return jsonify({"message":"Make sure your phone number must be filled"}), 400
    elif not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400
    elif len(phone) > 14:
        return jsonify({"message":"Make sure your phone number is at max 14 digits"}), 400
    elif len(phone) < 10:
        return jsonify({"message":"Make sure your phone number is at min 10 digits"}), 400

    company_formated = "%{}%".format(name)
    check_company = Company.query.filter(Company.name.like(company_formated)).first()
    if not check_company:
        code = "SMS/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Company.query.count() + 1)
        check_company = Company(code=code, name=name, email=email, phone=phone, is_active=0)
        db.session.add(check_company)
    db.session.commit()

    return jsonify({"message":"Success, Admin MACF will contact you soon"}), 200

@app.route('/v1/device_token/', methods=['POST'])
def device_token():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    token = request.form.get('token') or ''

    if token == '':
        return jsonify({"message":"Make sure your token must be filled"}), 400

    auth.device_token = token
    db.session.commit()
    return jsonify({"token":token}), 200

@app.route('/v1/account/', methods=['POST'])
def account_update():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    name = request.json.get('name') or ''
    address = request.json.get('address') or ''
    latlng = request.json.get('latlng') or ''

    if name == '':
        return jsonify({"message":"Make sure your name must be filled"}), 400            
    elif address == '':
        return jsonify({"message":"Make sure your address must be filled"}), 400

    partner = auth.partner
    if partner:
        partner.name = name
        company = partner.company
        if company:
            company.address = address
            if latlng != '':
                company.latlng = latlng
        db.session.commit()

        return jsonify({"message":"Account has been updated"}), 200
    return jsonify({"message":"Account not linked with partner"}), 400

@app.route('/v1/account-password/', methods=['POST'])
def account_password():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    password = request.json.get('password') or ''
    new_password = request.json.get('new_password') or ''

    if password == '':
        return jsonify({"message":"Make sure your password must be filled"}), 400            
    elif new_password == '':
        return jsonify({"message":"Make sure your new password must be filled"}), 400
    elif not auth.check_password(password):
        return jsonify({"message":"Password does not match, please try again"}), 400

    auth.password = generate_password_hash(new_password, method='sha256')

    db.session.commit()

    return jsonify({"message":"Password has been updated"}), 200

@app.route('/v1/customer/', methods=['GET'])
def customer_list():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    phone = request.args.get('phone') or ''  

    if not phone.isdigit():
        return jsonify({"message":"Make sure your phone number is valid only digit numeric"}), 400        

    search = "%{}%".format(phone)
    customers = Customer.query.filter(Customer.phone.like(search))

    return jsonify([item.serialize() for item in customers[0:10]])

@app.route('/v1/general/', methods=['GET'])
def general():
    from sqlalchemy import text
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401
    
    partner = auth.partner
    interest = None
    if partner and partner.company:
        interest = Interest.query.filter_by(type_id=partner.company.type_id, is_active=1).first()
    else:
        interest = Interest.query.filter_by(type_id=1, is_active=1).first()

    today = datetime.today().date()
    event_list = Event.query.filter(Event.start_date <= today).filter(Event.end_date >= today).order_by(Event.start_date.desc()).all()

    submission_stage = SubmissionStage.query.all()
    
    checking_status = syncStatus(request.headers.get("WWW-Authenticate"))
    return jsonify({'interest':interest.serialize(), 'event':[item.serialize() for item in event_list[0:5]], 'submission':[item.serialize(partner.id) for item in submission_stage]}), 200

@app.route('/v1/event/', methods=['GET'])
def event_list():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    page = request.args.get('page', 1, type=int)

    today = datetime.today().date()
    event_list = Event.query.filter(Event.start_date <= today).filter(Event.end_date >= today).all()

    offset = PAGINATE_LIST*(page-1)
    return jsonify([item.serialize() for item in event_list[offset:offset+PAGINATE_LIST]])

@app.route('/v1/event/', methods=['POST'])
def event_store():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    name = request.form.get('name') or ''
    image = request.files.get('image') or ''
    start_date = request.form.get('start_date') or ''
    end_date = request.form.get('end_date') or ''
    type_id = request.args.get('type_id', 1, type=int)

    if name == '':
        return jsonify({"message":"Make sure your name must be filled"}), 400
    elif image == '':
        return jsonify({"message":"Make sure your image must be taken"}), 400
    elif start_date == '':
        return jsonify({"message":"Make sure your start date must be filled"}), 400
    elif end_date == '':
        return jsonify({"message":"Make sure your end date must be filled"}), 400
    elif type_id > 3:
        return jsonify({"message":"Type Id not valid"}), 400

    if not allowed_image(image.filename):
        return jsonify({"message":"That file extension is not allowed"}), 400

    filename = "MACF_%s%s.%s" % (datetime.now().strftime("%d%H%M%S"), secrets.token_hex(10).upper(), image.filename.rsplit(".", 1)[1])
    image_path = "%s/event" % (app.config["IMAGE_UPLOADS"])
    if not os.path.exists(image_path):
        os.makedirs(image_path)
    image.save(os.path.join(image_path, filename))

    image_url = "%s/event/%s" % (app.config["IMAGE_URL"], filename)
    event = Event(name=name, image=image_url, start_date=start_date, end_date=end_date, type_id=type_id)
    db.session.add(event)
    db.session.commit()

    return jsonify(event.serialize()), 200

@app.route('/v1/notification/', methods=['GET'])
def notification_list():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    page = request.args.get('page', 1, type=int)

    notification_list = Notification.query.filter_by(user_id=auth.id).order_by(Notification.created_at.desc())

    offset = PAGINATE_LIST*(page-1)
    return jsonify([item.serialize() for item in notification_list[offset:offset+PAGINATE_LIST]])

@app.route('/v1/notification/<string:idx>/read/', methods=['GET'])
def notification_read(idx):
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    notification = Notification.query.filter_by(id=idx).first()
    if not notification:
        return jsonify({"message":"Notification is not valid"}), 400

    notification.is_read = 1
    db.session.commit()

    return jsonify({"message":"Notification has been read"}), 200

@app.route('/v1/cmo/', methods=['GET'])
def cmo_list():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    search = request.args.get('search') or ''
    page = request.args.get('page', 1, type=int)

    partner = auth.partner
    if not partner:
        return jsonify({"message":"Please Contact Admin!"}), 400

    dealer = PNDealer.query.filter_by(company_id=partner.company_id).first()
    if dealer:
        cmo = PNCMO.query.filter(PNCMO.branch_id.in_(dealer.branch)).all()
        if search != '':
            search = "%{}%".format(search)
            cmo = PNCMO.query.filter(PNCMO.branch_id.in_(dealer.branch)).filter(PNCMO.name.like(search)).all()

        offset = PAGINATE_LIST*(page-1)
        cmo = cmo[offset:offset+PAGINATE_LIST]
        return jsonify([item.serialize() for item in cmo])
    else:
        return jsonify([])

@app.route('/term/', methods=['GET'])
def term_condition():
    return render_template('term_condition.html')

@app.route('/privacy/', methods=['GET'])
def privacy():
    return render_template('privacy_policy.html')

@app.route('/v1/ocrFCL/', methods=['POST'])
def get_ocr_data():
    # Get Image
    image_ktp = request.files.get('image_ktp') or ''
    response = ''
    if image_ktp == '':
        return jsonify({"message":"No Image KTP"}), 400

     #Put Image KTP
    if not allowed_image(image_ktp.filename):
        return jsonify({"message":"That file KTP extension is not allowed"}), 400
    print('EXEC ---1')
    filename_ktp = "MACF_%s%s.%s" % (datetime.now().strftime("%d%H%M%S"), secrets.token_hex(10).upper(), image_ktp.filename.rsplit(".", 1)[1])
    image_path_ktp = "%s/ocr" % (app.config["IMAGE_UPLOADS"])
    if not os.path.exists(image_path_ktp):
        os.makedirs(image_path_ktp)
    image_ktp.save(os.path.join(image_path_ktp, filename_ktp))
    image_path = "%s/ocr/%s" % (app.config["IMAGE_UPLOADS"], filename_ktp)
    print('EXEC ---2')
    # Generate Base64 IMG
    with open("%s/%s" % (image_path_ktp, filename_ktp), "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
            data = {"img":encoded_string.decode('utf-8')}
            response_ocr = send_ocr_data(data, back=True)
            response = response_ocr['status']
   
    print('EXEC removing %s' % image_path)
    os.remove('./%s' % image_path)

    if response != 'OK':
        return jsonify({"message":"Image KTP not valid, Please take Image KTP !"}), 400
    print('EXEC ---4')
    return jsonify({"Detail":response_ocr, "message":"Success"}), 200

@app.route('/v1/product/', methods=['GET'])
def product():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    search = request.args.get('search') or ''
    page = request.args.get('page', 1, type=int)
    partner = auth.partner
    if partner and partner.company:
        type_id = partner.company.type_id
    else:
        type_id = 1
        
    masters = Master.query.filter_by(type_id=type_id)
    if search != '':
        search = "%{}%".format(search)
        masters = Master.query.filter_by(type_id=type_id).filter(Master.name.like(search)).all()

    offset = PAGINATE_LIST*(page-1)
    masters = masters[offset:offset+PAGINATE_LIST]
    return jsonify([item.serialize() for item in masters])

@app.route('/v1/product/', methods=['POST'])
def product_store():
    auth = customAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    name = request.form.get('name') or ''
    image = request.files.get('image') or ''
    category = request.form.get('category') or ''
    type_id = request.form.get('type_id', type=int) or 1
    brand = request.form.get('brand') or ''

    if name == '':
        return jsonify({"message":"Make sure your name must be filled"}), 400
    elif image == '':
        return jsonify({"message":"Make sure your image must be filled"}), 400
    elif category == '':
        return jsonify({"message":"Make sure your category must be filled"}), 400
    elif type_id > 3:
        return jsonify({"message":"Type Id not valid"}), 400
    elif brand == '':
        return jsonify({"message":"Make sure your brand must be filled"}), 400

    check_category = Category.query.filter_by(name=category).first()
    if not check_category:
        check_category = Category(name=category, type_id=type_id)
        db.session.add(check_category)

    check_brand = Brand.query.filter_by(name=brand).first()
    if not check_brand:
        check_brand = Brand(name=brand)
        db.session.add(check_brand)
    db.session.commit()

    check_product = Master.query.filter_by(name=name).first()
    if check_product:
        return jsonify({"message":"Product %r has been registered" % (name)}), 400

    if not allowed_image(image.filename):
        return jsonify({"message":"That file extension is not allowed"}), 400

    filename = "MACF_%s%s.%s" % (datetime.now().strftime("%d%H%M%S"), secrets.token_hex(10).upper(), image.filename.rsplit(".", 1)[1])
    image_path = "%s/product" % (app.config["IMAGE_UPLOADS"])
    if not os.path.exists(image_path):
        os.makedirs(image_path)
    image.save(os.path.join(image_path, filename))

    image_url = "%s/product/%s" % (app.config["IMAGE_URL"], filename)
    code = "SMS/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Master.query.filter_by(brand_id=check_brand.id, category_id=check_category.id, type_id=type_id).count() + 1)
    master = Master(code=code, name=name, image=image_url, brand_id=check_brand.id, category_id=check_category.id, type_id=type_id)
    db.session.add(master)
    db.session.commit()

    return jsonify(master.serialize()), 200

@app.route('/v1/submission/', methods=['GET'])
def submission_list():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    search = request.args.get('search') or ''
    page = request.args.get('page', 1, type=int)
    stage = request.args.get('stage', 0, type=int)
    limit = request.args.get('limit', PAGINATE_LIST, type=int)

    search = "%{}%".format(search)

    partner = auth.partner
    if stage == 0:
        submission_list = Submission.query.outerjoin(Customer, Submission.customer_id == Customer.id).filter(or_(Submission.code.like(search), Submission.product_name.like(search), Customer.name.like(search))).order_by(Submission.start_date.desc()).all()
    else:
        submission_list = Submission.query.outerjoin(Customer, Submission.customer_id == Customer.id).outerjoin(HREmployee, Submission.cmo == HREmployee.EmployeeID).filter(or_(Submission.code.like(search), Submission.product_name.like(search), Customer.name.like(search))).filter(Submission.stage_id==stage).order_by(Submission.start_date.desc()).all()

    if partner:
        if stage == 0:
            submission_list = Submission.query.outerjoin(Customer, Submission.customer_id == Customer.id).filter(or_(Submission.code.like(search), Submission.product_name.like(search), Customer.name.like(search))).filter(Submission.partner_id==partner.id).order_by(Submission.start_date.desc()).all()
        else:
            submission_list = Submission.query.outerjoin(Customer, Submission.customer_id == Customer.id).outerjoin(HREmployee, Submission.cmo == HREmployee.EmployeeID).filter(or_(Submission.code.like(search), Submission.product_name.like(search), Customer.name.like(search))).filter(Submission.partner_id==partner.id, Submission.stage_id==stage).order_by(Submission.start_date.desc()).all()
    offset = limit*(page-1)
    return jsonify([item.serialize() for item in submission_list[offset:offset+limit]])

@app.route('/v1/submission/', methods=['POST'])
def submission():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    master_id = request.form.get('master_id') or 0
    product_name = request.form.get('product_name') or ''
    cmo = request.form.get('cmo') or ''
    nik_cmo = re.search(r"\(([A-Za-z0-9_]+)\)", cmo) or '' 
    price = request.form.get('price') or '0'
    admin_fee = request.form.get('admin_fee') or '0'
    dp = request.form.get('dp') or '0'
    installment = request.form.get('installment') or '0'
    interest = request.form.get('interest') or '0'
    tenor = request.form.get('tenor') or '1'
    
    
    customer_phone = request.form.get('customer_phone') or ''
    image_ktp = request.files.get('image_ktp') or ''
    image_selfie = request.files.get('image_selfie') or ''

    # Data OCR
    customer_pob = ''
    customer_dob = ''
    customer_gender = ''
    customer_rt = ''
    customer_rw = ''
    customer_village = ''
    customer_district = ''
    customer_religion = ''
    customer_marital_status = ''
    customer_work = ''
    customer_nationnality = ''
    customer_city = ''
    customer_province = ''
    customer_name = request.form.get('customer_name') or ''
    customer_address = request.form.get('customer_address') or ''
    customer_nik = request.form.get('customer_nik') or ''
    ocr_pob = request.form.get('ocr_pob') or ''
    ocr_dob = request.form.get('ocr_dob') or ''
    ocr_address = request.form.get('ocr_address') or ''
    ocr_gender = request.form.get('ocr_gender') or ''
    ocr_rt = request.form.get('ocr_rt') or ''
    ocr_rw = request.form.get('ocr_rw') or ''
    ocr_village = request.form.get('ocr_village') or ''
    ocr_district = request.form.get('ocr_district') or ''
    ocr_religion = request.form.get('ocr_religion') or ''
    ocr_marital_status = request.form.get('ocr_marital_status') or ''
    ocr_work = request.form.get('ocr_work') or ''
    ocr_nationnality = request.form.get('ocr_nationnality') or ''


    if product_name == '':
        return jsonify({"message":"Make sure your Product Name must be filled"}), 400
    elif cmo == '': 
        return jsonify({"message":"Make sure your CMO must be filled"}), 400
    elif nik_cmo == '':
        return jsonify({"message":"Make sure your CMO is using valid format"}), 400
    elif nik_cmo.group(1) == '':
        return jsonify({"message":"Make sure your CMO is using valid format"}), 400    
    elif len(nik_cmo.group(1)) > 9 | len(nik_cmo.group(1)) < 9:
        return jsonify({"message":"Make sure your CMO is using valid format"}), 400
    elif not price.isdigit(): 
        return jsonify({"message":"Make sure your price is valid only numeric"}), 400
    elif int(price) < 1000:
        return jsonify({"message":"Make sure your price is valid"}), 400
    elif not admin_fee.isdigit(): 
        return jsonify({"message":"Make sure your admin fee is valid only numeric"}), 400
    elif int(admin_fee) < 1000:
        return jsonify({"message":"Make sure your admin fee is valid"}), 400
    elif not dp.isdigit(): 
        return jsonify({"message":"Make sure your dp is valid only numeric"}), 400
    elif int(dp) < 1000:
        return jsonify({"message":"Make sure your dp is valid"}), 400
    elif int(dp) > int(price):
        return jsonify({"message":"Make sure your dp is not greater than the price"}), 400
    elif not installment.isdigit(): 
        return jsonify({"message":"Make sure your installment is valid only numeric"}), 400
    elif int(installment) < 1000:
        return jsonify({"message":"Make sure your installment is valid"}), 400
    elif not tenor.isdigit(): 
        return jsonify({"message":"Make sure your tenor is valid only numeric"}), 400
    elif int(tenor) < 1:
        return jsonify({"message":"Make sure your tenor is valid"}), 400
    elif customer_name == '':
        return jsonify({"message":"Make sure your customer name must be filled"}), 400
    elif customer_phone == '':
        return jsonify({"message":"Make sure your customer phone must be filled"}), 400
    elif not customer_phone.isdigit(): 
        return jsonify({"message":"Make sure your customer phone is valid only numeric"}), 400
    elif len(customer_phone) > 14:
        return jsonify({"message":"Make sure your customer phone is at max 14 digits"}), 400
    elif len(customer_phone) < 10:
        return jsonify({"message":"Make sure your customer phone is at min 10 digits"}), 400
    elif customer_phone[0] == '0':
        return jsonify({"message":"Make sure your customer phone is start without 0"}), 400
    elif image_ktp == '':
        return jsonify({"message":"Make sure your image ktp must be taken"}), 400
    elif image_selfie == '':
        return jsonify({"message":"Make sure your image selfie must be taken"}), 400

    amount = int(price) - int(dp)

    check_customer = Customer.query.filter_by(phone=customer_phone).first()
    if not check_customer:
        #Generate Image KTP
        if not allowed_image(image_ktp.filename):
            return jsonify({"message":"That file KTP extension is not allowed"}), 400
        filename_ktp = "MACF_%s%s.%s" % (datetime.now().strftime("%d%H%M%S"), secrets.token_hex(10).upper(), image_ktp.filename.rsplit(".", 1)[1])
        image_path_ktp = "%s/ktp" % (app.config["IMAGE_UPLOADS"])
        if not os.path.exists(image_path_ktp):
            os.makedirs(image_path_ktp)
        image_ktp.save(os.path.join(image_path_ktp, filename_ktp))

        image_ktp_url = "%s/ktp/%s" % (app.config["IMAGE_URL"], filename_ktp)

        #Generate Image Selfie
        if not allowed_image(image_selfie.filename):
            return jsonify({"message":"That file Selfie extension is not allowed"}), 400
        filename_selfie = "MACF_%s%s.%s" % (datetime.now().strftime("%d%H%M%S"), secrets.token_hex(10).upper(), image_selfie.filename.rsplit(".", 1)[1])
        image_path_selfie = "%s/selfie" % (app.config["IMAGE_UPLOADS"])
        if not os.path.exists(image_path_selfie):
            os.makedirs(image_path_selfie)
        image_selfie.save(os.path.join(image_path_selfie, filename_selfie))

        image_selfie_url = "%s/selfie/%s" % (app.config["IMAGE_URL"], filename_selfie)

        #Generate Base64 KTP
        # with open("%s/%s" % (image_path_ktp, filename_ktp), "rb") as image_file:
        #     encoded_string = base64.b64encode(image_file.read())

        #     data = {"img":encoded_string.decode('utf-8')}
        #     response_ocr = send_ocr_data(data, back=True)
            
        #     if response_ocr['status'] != 'OK':
        #         return jsonify({"message":"Image KTP not valid, Please take Image KTP !"}), 400

        #     customer_nik = response_ocr['id']
        #     customer_name_ocr = response_ocr['name']
        #     customer_pob = response_ocr['pob']
        #     customer_dob = response_ocr['dob']
        #     customer_gender = response_ocr['gender']
        #     customer_rt = response_ocr['rt']
        #     customer_rw = response_ocr['rw']
        #     customer_village = response_ocr['village']
        #     customer_district = response_ocr['district']
        #     customer_religion = response_ocr['religion']
        #     customer_marital_status = response_ocr['marital_status']
        #     customer_work = response_ocr['work']
        #     customer_nationnality = response_ocr['nationnality']
        #     customer_city = response_ocr['city']
        #     customer_province = response_ocr['province']
        #     customer_address = response_ocr['address']

        #     print(customer_pob ,customer_dob ,customer_gender ,customer_rt ,customer_rw ,customer_village ,customer_district ,customer_religion ,customer_marital_status ,customer_work ,customer_nationnality ,customer_city ,customer_province )

        code = "DESC/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Customer.query.count() + 1)

        check_customer = Customer(code=code, name=customer_name, phone=customer_phone, nik=customer_nik, address=customer_address, photo_ktp=image_ktp_url, photo_selfie=image_selfie_url)
        db.session.add(check_customer)
        db.session.commit()

    if master_id == '0':
        search_product = "%{}%".format(product_name)
        check_master = Master.query.filter(Master.name.like(search_product)).first()
        if not check_master:
            code = "DESC/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Master.query.count() + 1)
            check_master = Master(code=code, name=product_name, type_id=auth.partner.company.type_id)
            db.session.add(check_master)
            db.session.commit()
        master_id = check_master.id

    code = "DESC/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Submission.query.count() + 1)
    submission = Submission(code=code, partner_id=auth.partner.id, customer_id=check_customer.id, cmo=nik_cmo.group(1), master_id=master_id, product_name=product_name, price=price, amount=amount, admin_fee=admin_fee, dp=dp, interest=interest, installment=installment, tenor=tenor, stage_id=1)
    db.session.add(submission)
    db.session.commit()

    if customer_nik != "":
        code = "DESC/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), SubmissionDetail.query.count() + 1)
        submissionDetail = SubmissionDetail(SubmissionID = submission.id, Code = code, NIK = customer_nik, Nama = customer_name, TempatLahir = ocr_pob, TanggalLahir = ocr_dob, JenisKelamin = ocr_gender, Alamat = ocr_address, RT = ocr_rt, RW = ocr_rw, Kelurahan = ocr_village, Kecamatan = ocr_district, Agama = ocr_religion, StatusPerkawinan = ocr_marital_status, Pekerjaan = ocr_work, Kewarganegaraan = ocr_nationnality)
        db.session.add(submissionDetail)
        db.session.commit()


    # Generate Notification
    submission.generate_notification()

    return jsonify(submission.serialize()), 200

@app.route('/v1/printPO/', methods=['GET'])
def print_po():
    auth = loginAuthorization(request.headers.get("WWW-Authenticate"))
    if not auth:
        return jsonify({"message":"Authorization access is required"}), 401

    submission_id = request.args.get('submission_id') or 0
    
    if submission_id == 0 :
        return jsonify({"message":"Please Try Again"}), 401
    
    connection = db_raw.raw_connection()
    cursor = connection.cursor()
    result = cursor.execute("spPrintPODecs ?", [int(submission_id)]).fetchall()
    cursor.commit()

    filePath = result[0][4] or ''
    fileName = result[0][5] or ''

    filePath = '\\\\MACF-FILE\\FileExportPDF' or ''
    # filePath = app.config["SHARE_PATH"] or ''
    # fileName = '6182200035_PO_report.pdf' or ''

    if filePath == '' or fileName == '' :
        return jsonify({"message":"Purchase order file not available"}), 401

    # filePath = filePath.replace("\\","\\\\")
    fileToPath = filePath+fileName
    user = getpass.getuser()
    print("Usere "+user)

    # if not networkConnection(filePath):
    #     return jsonify({"message":"Conncetion Error, Please Try Again "+ user}), 401

    if not os.path.isfile(fileToPath):
        return jsonify({"message":"Error, please try again"}), 401

    with open(fileToPath, "rb") as pdf_file:
        encoded_string = base64.b64encode(pdf_file.read())

    return jsonify({"message":"Success", "filename": fileName, "filepath" : filePath, "pdffile":str(encoded_string)}), 200


def allowed_image(filename):
    if not "." in filename:
        return False

    ext = filename.rsplit(".", 1)[1]

    if ext.upper() in app.config["ALLOWED_IMAGE_EXTENSIONS"]:
        return True
    else:
        return False

def networkConnection(networkAddress):
    share_full_name  = networkAddress
    share_user = "\\".join((app.config["SHARE_DOMAIN"], app.config["SHARE_USER"]))
    share_pwd = app.config["SHARE_PASSWORD"]

    net_resource = wNet.NETRESOURCE()
    net_resource.lpRemoteName = share_full_name
    net_resource.dwScope = wCon.RESOURCE_GLOBALNET
    net_resource.dwType =  wCon.RESOURCETYPE_DISK
    net_resource.dwUsage = wCon.RESOURCEUSAGE_CONNECTABLE
    flags = 0
    #flags |= CONNECT_INTERACTIVE

	
    print("Trying to create connection to: {:s}".format(share_full_name))
    try:
        wNet.WNetAddConnection2(net_resource, share_pwd, share_user, flags)
    except Exception as e:
        print(e)
        return False
    else:
        print("Success!")
        return True

if __name__ == '__main__':
    import logging
    logging.basicConfig(filename='account.log',level=logging.DEBUG)
    
    serve(app, host='0.0.0.0', port=3637)