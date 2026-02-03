import json
import secrets
import base64

from flask import Flask, jsonify
from flask_serialize import FlaskSerializeMixin
from werkzeug.security import check_password_hash
from datetime import datetime, timedelta
from random import randint
from tools import send_fcm_notification

from settings import db, app

class Application(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_application'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    client = db.Column(db.String(100), nullable=False)
    redirect_url = db.Column(db.Text, nullable=False)
    app_type = db.Column(db.String(30), nullable=False)
    client_secret = db.Column(db.String(255), nullable=False)
    name = db.Column(db.String(60))
    min_version = db.Column(db.SmallInteger)
    current_version = db.Column(db.SmallInteger)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<Application %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'name'              : self.name,
            'min_version'       : self.min_version,
            'current_version'   : self.current_version,
            'created_at'        : self.created_at,
        }

class AccessToken(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_access_token'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    token = db.Column(db.String(255), nullable=True)
    expires = db.Column(db.DateTime(), nullable=True)
    application_id = db.Column(db.Integer, db.ForeignKey('tbl_application.id'), nullable=False)
    refresh_token_id = db.Column(db.BigInteger, nullable=True)
    user_id = db.Column(db.BigInteger, db.ForeignKey('tbl_user.id'), nullable=False)
    created_at = db.Column(db.DateTime(), default=datetime.now)
    updated_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<AccessToken %r>' % (self.user.email)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'token'         : self.token,
            'expires'       : self.expires,
        }

    @property
    def user(self):
        user = User.query.filter_by(id=self.user_id).first()
        return user if user else None

class RefreshToken(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_refresh_token'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    token = db.Column(db.String(255), nullable=True)
    application_id = db.Column(db.Integer, db.ForeignKey('tbl_application.id'), nullable=False)
    user_id = db.Column(db.BigInteger, db.ForeignKey('tbl_user.id'), nullable=False)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<RefreshToken %r>' % (self.user.email)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'token'         : self.token,
        }

class User(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_user'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    email = db.Column(db.String(120), unique=True, nullable=True)
    phone = db.Column(db.String(14), unique=True, nullable=False)
    password = db.Column(db.String(120), unique=True, nullable=False)
    device_token = db.Column(db.String(120), unique=True, nullable=True)
    is_active = db.Column(db.SmallInteger, default=0)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<User %r>' % (self.email)

    def serialize(self):
        """Return object data in easily serializable format"""
        if self.partner:
            return {
                'email'         : self.email,
                'phone'         : self.phone,
                'name'          : self.partner.name,
                'company'       : self.company.name if self.company else "",
                'type_id'       : self.company.type_id if self.company else "",
                'created_at'    : self.created_at,
            }
        return {
            'email'         : self.email,
            'phone'         : self.phone,
            'created_at'    : self.created_at,
        }

    def login_serialize(self):
        """Return object data in easily serializable format"""
        return {
            'email'         : self.email,
            'phone'         : self.phone,
            'name'          : self.partner.name,
            'company'       : self.company.name if self.company else "",
            'type_id'       : self.company.type_id if self.company else 1,
            'address'       : self.company.address if self.company else "",
            'token'         : self.token,
        }

    @property
    def company(self):
        if self.partner and self.partner.company:
            return self.partner.company
        return None

    @property
    def partner(self):
        partner = Partner.query.filter_by(user_id=self.id).first()
        return partner if partner else None

    @property
    def token(self):
        access = AccessToken.query.filter_by(user_id=self.id).first()
        return access.token if access else None

    def signout_token(self):
        self.device_token = None

        access = AccessToken.query.filter_by(user_id=self.id).first()
        access.token = None

        db.session.commit()

    def check_password(self, password):
        return check_password_hash(self.password, password)

    def generate_token(self, application):
        expired = datetime.now() + timedelta(days=366)
        token = secrets.token_hex(120)

        #Create Refresh Token User Login
        refresh_token = RefreshToken(token=token, application_id=application.id, user_id=self.id)
        db.session.add(refresh_token)

        #Check current Access Token on this Application
        check_token = AccessToken.query.filter_by(user_id=self.id).first()
        if not check_token:
            check_token = AccessToken(token=token, expires=expired, application_id=application.id, refresh_token_id=refresh_token.id, user_id=self.id)
            db.session.add(check_token)
        else:
            check_token.token = token
            check_token.application_id = application.id
            check_token.refresh_token_id = refresh_token.id
            check_token.updated_at = datetime.now()
        db.session.commit()
        return check_token

    def check_forgot_token_time(self, token):
        result = False
        check_token = UserForgot.query.filter(UserForgot.user_id==self.id, UserForgot.code!='EXPIRED').all()
        for forgot_token in check_token:
            if forgot_token.code == token and forgot_token.expired_time >= datetime.now():
                result = True
        return result

    def check_forgot_token(self, token):
        result = False
        check_token = UserForgot.query.filter(UserForgot.user_id==self.id, UserForgot.code!='EXPIRED').all()
        for forgot_token in check_token:
            if forgot_token.code == token:
                result = True
        return result

    def success_check_forgot_token(self):
        check_forgot = UserForgot.query.filter(UserForgot.user_id==self.id, UserForgot.code!='EXPIRED').all()
        for forgot in check_forgot:
            forgot.code='EXPIRED'
        db.session.commit()

    def generate_sms_forgot_password_token(self):
        from tools import send_otp_sms
        
        expired = datetime.now() + timedelta(minutes=5)
        token = randint(100000, 999999)

        check_token = UserForgot.query.filter(UserForgot.user_id==self.id, UserForgot.code!='EXPIRED').all()
        for forgot_token in check_token:
            forgot_token.code='EXPIRED'

        #SMS OTP Now
        message = "WASPADA PENIPUAN. Jangan memberikan kode ini kepada pihak manapun. Masukkan Kode: %d untuk melanjutkan aktivasi di DECS Mobile" % token
        data = {"userid": "mcfotp2", "password": "mcfotp28765", "msisdn": self.phone, "division": "corporate planning", "sender": "MCF", "batchnme": token, "channel": 2, "uploadby": self.partner.name, "message": message}
        send_otp_sms(data)

        user_forgot = UserForgot(user_id=self.id, code=token, old_password=self.password, expired_time=expired)
        db.session.add(user_forgot)
        db.session.commit()

class UserForgot(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_user_forgot'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.BigInteger, db.ForeignKey('tbl_user.id'), nullable=False)
    code = db.Column(db.String(50), nullable=False)
    old_password = db.Column(db.String(120), unique=True, nullable=False)
    expired_time = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<UserForgot %r>' % (self.code)

class Company(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_company'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    npwp = db.Column(db.String(20), nullable=True)
    email = db.Column(db.String(120), nullable=True)
    phone = db.Column(db.String(14), nullable=True)
    address = db.Column(db.Text, nullable=True)
    latlng = db.Column(db.String(40), nullable=True)
    type_id = db.Column(db.BigInteger, db.ForeignKey('tbl_product_type.id'), nullable=False)
    is_active = db.Column(db.SmallInteger, default=0)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<Company %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'code'         : self.code,
            'name'         : self.name,
            'npwp'         : self.npwp,
            'email'        : self.email,
            'phone'        : self.phone,
            'type_id'      : self.type_id,
        }

class Partner(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_partner'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    user_id = db.Column(db.BigInteger, db.ForeignKey('tbl_user.id'), nullable=False)
    company_id = db.Column(db.BigInteger, db.ForeignKey('tbl_company.id'), nullable=False)
    is_active = db.Column(db.SmallInteger, default=0)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<Partner %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'name'       : self.name,
            'address'    : self.address,
            'latlng'     : self.latlng,
            'created_at' : self.created_at,
        }

    @property
    def company(self):
        company = Company.query.filter_by(id=self.company_id).first()
        return company if company else None

    @property
    def user(self):
        user = User.query.filter_by(id=self.user_id).first()
        return user if user else None

class Customer(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_customer'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(120), nullable=False)
    nik = db.Column(db.String(20), nullable=True)
    address = db.Column(db.Text, nullable=True)
    phone = db.Column(db.String(14), unique=True, nullable=False)
    photo_ktp = db.Column(db.String(255), nullable=False)
    photo_selfie = db.Column(db.String(255), nullable=False)
    join_date = db.Column(db.DateTime(), default=datetime.now)
    is_active = db.Column(db.SmallInteger, default=0)

    def __repr__(self):
        return '<Customer %r>' % (self.name)

    @property
    def photo_ktp_url(self):
        return ":5000/%s" % self.photo_ktp if self.photo_ktp else ""

    @property
    def photo_selfie_url(self):
        return ":5000/%s" % self.photo_selfie if self.photo_selfie else ""

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'code'          : self.code,
            'name'          : self.name,
            'nik'           : self.nik,
            'address'       : self.address,
            'phone'         : self.phone,
        }

class ProductType(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_product_type'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return '<ProductType %r>' % (self.name)

class Interest(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_interest'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    min_dp = db.Column(db.Float, default=10, nullable=False)
    amount = db.Column(db.Float, nullable=False)
    admin_fee = db.Column(db.String(12), nullable=True)
    type_id = db.Column(db.SmallInteger, db.ForeignKey('tbl_product_type.id'), nullable=False)
    is_active = db.Column(db.SmallInteger, default=0)

    def __repr__(self):
        return '<Interest %r>' % (self.amount)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'min_dp'    : self.min_dp,
            'interest'  : self.amount,
            'admin_fee' : self.admin_fee,
        }

class Event(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_event'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=True)
    image = db.Column(db.String(255), nullable=True)
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    type_id = db.Column(db.SmallInteger, db.ForeignKey('tbl_product_type.id'), nullable=False)

    def __repr__(self):
        return '<Event %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'name'      : self.name,
            'image_url' : self.image_url,
            'start_date': self.start_date.strftime("%Y-%m-%d"),
            'end_date'  : self.end_date.strftime("%Y-%m-%d"),
        }

    @property
    def image_url(self):
        return ":5000/%s" % self.image if self.image else ""

class NotificationType(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_notification_type'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=True)

    def __repr__(self):
        return '<NotificationType %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'name'      : self.name,
        }

class Notification(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_notification'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String(50), nullable=False)
    content = db.Column(db.Text, nullable=False)
    image = db.Column(db.String(255), nullable=True)
    redirect = db.Column(db.String(255), nullable=True)
    type_id = db.Column(db.Integer, nullable=True)
    user_id = db.Column(db.BigInteger, db.ForeignKey('tbl_user.id'), nullable=False)
    is_read = db.Column(db.SmallInteger, default=0)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<Notification %r>' % (self.title)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'id'            : self.id,
            'title'         : self.title,
            'content'       : self.content,
            'image'         : self.image_url,
            'redirect'      : self.redirect,
            'type_id'       : self.type_id,
            'is_read'       : self.is_read,
            'created_at'    : self.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        }

    @property
    def image_url(self):
        return ":5000/%s" % self.image if self.image else ""

class SubmissionStage(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_submission_stage'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.SmallInteger, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return '<SubmissionStage %r>' % (self.name)

    def serialize(self, partner_id):
        """Return object data in easily serializable format"""
        return {
            'id'        : self.id,
            'name'      : self.name,
            'count'     : Submission.query.filter_by(stage_id=self.id, partner_id=partner_id).count(),
        }

class Submission(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_submission'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    partner_id = db.Column(db.BigInteger, db.ForeignKey('tbl_partner.id'), nullable=False)
    customer_id = db.Column(db.BigInteger, db.ForeignKey('tbl_customer.id'), nullable=False)
    master_id = db.Column(db.BigInteger, db.ForeignKey('tbl_master.id'), nullable=False)
    product_name = db.Column(db.String(150), nullable=False)
    cmo = db.Column(db.String(20), db.ForeignKey('tbl_master.id'), nullable=True)
    price = db.Column(db.String(12), default=0)
    admin_fee = db.Column(db.String(12), default=0)
    dp = db.Column(db.String(12), default=0)
    amount = db.Column(db.String(12), default=0)
    interest = db.Column(db.Float, default=0)
    installment = db.Column(db.String(12), default=0)
    tenor = db.Column(db.SmallInteger, default=0)
    start_date = db.Column(db.DateTime(), default=datetime.now)
    stage_id = db.Column(db.SmallInteger, db.ForeignKey('tbl_submission_stage.id'), nullable=False)

    def __repr__(self):
        return '<Submission %r>' % (self.code)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'id'            : self.id,
            'code'			: self.code,
            'product_name'	: self.product_name,
            'product_url'   : self.master.image_url if self.master else None,
            'customer'    	: self.customer.name,
            'cmo'           : self.cmo_name,
            'phone'     	: self.customer.phone,
            'amount'		: self.amount,
            'tenor'			: self.tenor,
            'stage'			: self.stage.name,
            'price'			: self.price,
            'dp'            : self.dp,
            'admin_fee'     : self.admin_fee,
            'installment'   : self.installment,
            'ktp_url'       : self.customer.photo_ktp_url,
            'self_url'      : self.customer.photo_selfie_url,
            'start_date' 	: self.start_date.strftime("%Y-%m-%d %H:%M:%S"),
        }

    @property
    def partner(self):
        partner = Partner.query.filter_by(id=self.partner_id).first()
        return partner if partner else None

    @property
    def customer(self):
        customer = Customer.query.filter_by(id=self.customer_id).first()
        return customer if customer else None

    @property
    def master(self):
        master = Master.query.filter_by(id=self.master_id).first()
        return master if master else None

    @property
    def stage(self):
        stage = SubmissionStage.query.filter_by(id=self.stage_id).first()
        return stage if stage else None

    @property
    def cmo_name(self):
        cmo = HREmployee.query.filter_by(EmployeeID=self.cmo).first()
        return cmo.EmployeeName if cmo else "-"

    def generate_notification(self):
        if self.partner and self.partner.user:
            notification = Notification(title="Pengajuan %s" % self.product_name, content="Pengajuan anda akan dilakukan proses verifikasi 1x24jam", image=self.master.image_url, redirect="", type_id=3, user_id=self.partner.user.id)
            db.session.add(notification)
            db.session.commit()

            message = json.dumps({'id': notification.id, 'content': notification.content, 'type_id': notification.type_id, 'created_at': notification.created_at.strftime("%Y-%m-%dT%H:%M:%S.%fZ")})
            data = {'registration_ids': [self.partner.user.device_token], 'data':{'Title': notification.title, 'Description': "Pengajuan Anda akan dilakukan proses verifikasi!", 'Message': message}}
            send_fcm_notification(data, verbose=True)
        return None

class PNBranch(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_pn_branch'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    name = db.Column(db.String(120), nullable=False)

    def __repr__(self):
        return '<Branch %r>' % (self.name)

class PNDealer(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_pn_dealer'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(120), nullable=False)
    company_id = db.Column(db.BigInteger, db.ForeignKey('tbl_company.id'), nullable=False)

    def __repr__(self):
        return '<Dealer %r>' % (self.name)

    @property
    def branch(self):
        list_branch = PNDealerBranch.query.filter_by(dealer_id=self.id).all()
        return (item.branch_id for item in list_branch)

class PNDealerBranch(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_pn_dealer_branch'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    dealer_id = db.Column(db.BigInteger, db.ForeignKey('tbl_pn_dealer.id'), nullable=False)
    branch_id = db.Column(db.BigInteger, db.ForeignKey('tbl_pn_branch.id'), nullable=False)

    def __repr__(self):
        return '<DealerBranch %r>' % (self.id)

class PNCMO(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_pn_cmo'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(120), nullable=False)
    branch_id = db.Column(db.BigInteger, db.ForeignKey('tbl_pn_branch.id'), nullable=False)

    def __repr__(self):
        return '<CMO %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'id'        : self.code,
            'name'      : self.name,
        }

class OCRDetail:
    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__, 
            sort_keys=True, indent=4)

class Master(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_master'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    code = db.Column(db.String(20), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    image = db.Column(db.String(255), nullable=True)
    type_id = db.Column(db.SmallInteger, db.ForeignKey('tbl_product_type.id'), nullable=False)
    brand_id = db.Column(db.Integer, db.ForeignKey('tbl_brand.id'), nullable=True)
    category_id = db.Column(db.BigInteger, db.ForeignKey('tbl_category.id'), nullable=True)
    created_at = db.Column(db.DateTime(), default=datetime.now)

    def __repr__(self):
        return '<Master %r>' % (self.name)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'id'        : self.id,
            'code'      : self.code,
            'name'     	: self.name,
            'image_url'	: self.image_url,
            'brand'    	: self.brand,
            'category'	: self.category,
        }

    @property
    def image_url(self):
        return ":5000/%s" % self.image if self.image else ""

    @property
    def brand(self):
        brand = Brand.query.filter_by(id=self.brand_id).first()
        return brand.name if brand else None

    @property
    def category(self):
        category = Category.query.filter_by(id=self.category_id).first()
        return category.name if category else None

class Category(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_category'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    total_product = db.Column(db.Integer, default=0)
    type_id = db.Column(db.SmallInteger, db.ForeignKey('tbl_product_type.id'), nullable=False)

    def __repr__(self):
        return '<Category %r>' % (self.name)

class Brand(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_brand'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(100), nullable=False)
    total_product = db.Column(db.Integer, default=0)

    def __repr__(self):
        return '<Brand %r>' % (self.name)

class SubmissionDetail(db.Model, FlaskSerializeMixin):
    __tablename__ = 'tbl_submission_detail'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    SubmissionID  = db.Column(db.BigInteger, db.ForeignKey('tbl_submission.id'), nullable=False)
    Code = db.Column(db.String(20), nullable=True)
    NIK = db.Column(db.String(20), nullable=True)
    Nama = db.Column(db.String(45), nullable=True)
    TempatLahir = db.Column(db.String(45), nullable=True)
    TanggalLahir = db.Column(db.String(20), nullable=True)
    JenisKelamin = db.Column(db.String(15), nullable=True)
    Alamat = db.Column(db.String(255), nullable=True)
    RT = db.Column(db.String(5), nullable=True)
    RW = db.Column(db.String(5), nullable=True)
    Kelurahan = db.Column(db.String(100), nullable=True)
    Kecamatan = db.Column(db.String(100), nullable=True)
    Agama = db.Column(db.String(30), nullable=True)
    StatusPerkawinan = db.Column(db.String(30), nullable=True)
    Pekerjaan = db.Column(db.String(45), nullable=True)
    Kewarganegaraan = db.Column(db.String(5), nullable=True)
    

    def __repr__(self):
        return '<Token %r>' % (self.token)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'id'        : self.id
            ,'SubmissionID' : self.SubmissionID
            ,'Code' : self.Code
            ,'NIK' : self.NIK
            ,'Nama' : self.Nama
            ,'TempatLahir' : self.TempatLahir
            ,'TanggalLahir' : self.TanggalLahir
            ,'JenisKelamin' : self.JenisKelamin
            ,'Alamat' : self.Alamat
            ,'RT' : self.RT
            ,'RW' : self.RW
            ,'Kelurahan' : self.Kelurahan
            ,'Kecamatan' : self.Kecamatan
            ,'Agama' : self.Agama
            ,'StatusPerkawinan' : self.StatusPerkawinan
            ,'Pekerjaan' : self.Pekerjaan
            ,'Kewarganegaraan' : self.Kewarganegaraan
        }

class HREmployee(db.Model, FlaskSerializeMixin):
    __tablename__ = 'vw_HREmployeeData'
    __table_args__ = {'extend_existing': True}

    EmployeeID = db.Column(db.String(20), primary_key=True)
    EmployeeName = db.Column(db.String(50), nullable=True)
    

    def __repr__(self):
        return '<Token %r>' % (self.token)

    def serialize(self):
        """Return object data in easily serializable format"""
        return {
            'EmployeeID'        : self.EmployeeID,
            'EmployeeName'       : self.EmployeeName
        }

class UserLogin(db.Model, FlaskSerializeMixin):
    __tablename__ = 'USERLOGIN'
    __table_args__ = {'extend_existing': True}

    nik = db.Column(db.String(10), primary_key=True)
    password = db.Column(db.String(255), nullable=False)
    pin = db.Column(db.String(6), nullable=False)
    isactive = db.Column(db.String(1), nullable=False)

    def __repr__(self):
        return '<UserLogin %r>' % (self.name)

    def serialize(self, partner_id):
        """Return object data in easily serializable format"""
        return {
            'id'        : self.nik,
            'isactive'      : self.isactive,
        }

db.init_app(app)