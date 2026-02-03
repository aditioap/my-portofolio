import urllib.request
import urllib.parse
import json
import ssl

# import openpyxl
from pathlib import Path
from datetime import datetime
from werkzeug.security import generate_password_hash

from settings import db, app
# from models import PNBranch, PNDealer, PNDealerBranch, PNCMO, User, Company, Partner

def send_fcm_notification(data, verbose=False, back=False):
    url = 'https://fcm.googleapis.com/fcm/send'
    params = json.dumps(data).encode('UTF-8')
    rq = urllib.request.Request(url, data=params)
    rq.add_header('Authorization', 'key=AAAADoH4RXA:APA91bFGZT6GvKHfy1kfobk2Sr8MM_cbVb0P1s5nUwg5H7sUUQ7QAqwieEKNzkBkXcZBBczXSqDJmlLnyFNlia-TDE4Ckbs_KbMpUar1OGiIknvJlySKvnkJnrxJwZ5fLY8FZzqvpM9f')   # fcm token id
    rq.add_header('Content-Type', 'application/json')
    try:
        gcontext = ssl.SSLContext()
        res = urllib.request.urlopen(rq, context=gcontext)
        cc = res.read()
        if verbose:
            print(cc)
        if back:
            encoding = res.info().get_content_charset('utf-8')
            return json.loads(cc.decode(encoding))
    except (urllib.error.HTTPError, urllib.error.URLError) as e:
        print(e)

def send_ocr_data(data, verbose=False, back=False):
    url = 'https://macfto.mcf.co.id/DataVerification/api/OCRMobile'
    params = urllib.parse.urlencode(data).encode('UTF-8')
    rq = urllib.request.Request(url, data=params)
    rq.add_header('R-Key', '44a062722338be3f57e6374b3bda1286')   # fcm token id
    rq.add_header("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
    rq.add_header("User-Agent", "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0")
    try:
        gcontext = ssl.SSLContext()
        res = urllib.request.urlopen(rq, context=gcontext)
        cc = res.read()
        if verbose:
            print(cc)
        if back:
            encoding = res.info().get_content_charset('utf-8')
            return json.loads(cc.decode(encoding))
    except (urllib.error.HTTPError, urllib.error.URLError) as e:
        print(e)

def send_otp_sms(data, verbose=False, back=False):
    url = 'https://apismsbroadcast.detik.com/index.ashx'
    params = urllib.parse.urlencode(data)
    try:
        res = urllib.request.urlopen(url + '?' + params)
        cc = res.read()
        if verbose:
            print(cc)
        if back:
            encoding = res.info().get_content_charset('utf-8')
            return json.loads(cc.decode(encoding))
    except (urllib.error.HTTPError, urllib.error.URLError) as e:
        print(e)

# def import_branch_xlsx():
#     xlsx_file = Path('master_branch.xlsx')
#     wb_obj = openpyxl.load_workbook(xlsx_file) 
#     sheet = wb_obj.active

#     for i, row in enumerate(sheet.iter_rows(values_only=True)):
#         if i > 0:
#             db.session.add(PNBranch(id=row[0], name=row[1]))
#             db.session.commit()


# def import_cmo_xlsx():
#     xlsx_file = Path('agentcmo.xlsx')
#     wb_obj = openpyxl.load_workbook(xlsx_file) 
#     sheet = wb_obj.active

#     for i, row in enumerate(sheet.iter_rows(values_only=True)):
#         if i > 0:
#             branch = PNBranch.query.filter_by(id=row[2]).first()
#             if not branch:
#                 branch = PNBranch(id=row[2], name="unknown")
#                 db.session.add(branch)
#                 db.session.commit()

#             db.session.add(PNCMO(code=row[0], name=row[1], branch_id=branch.id))
#             db.session.commit()


# def import_dealer_xlsx():
#     xlsx_file = Path('dealer_branch.xlsx')
#     wb_obj = openpyxl.load_workbook(xlsx_file) 
#     sheet = wb_obj.active

#     for i, row in enumerate(sheet.iter_rows(values_only=True)):
#         if i > 0:
#             dealer = PNDealer.query.filter_by(code=row[0]).first()
#             if not dealer:
#                 print(row[1])
#                 company_formated = "%{}%".format(str(row[1]).rstrip())
#                 check_company = Company.query.filter(Company.name.like(company_formated)).first()
#                 if not check_company:
#                     code = "SMS/%s/MACF/%05d" % (datetime.now().strftime('%y%m'), Company.query.count() + 1)
#                     check_company = Company(code=code, name=str(row[1]).rstrip(), is_active=1, type_id=1)
#                     db.session.add(check_company)
#                     db.session.commit()

#                 dealer = PNDealer(code=row[0], name=str(row[1]).rstrip(), company_id=check_company.id)
#                 db.session.add(dealer)
#                 db.session.commit()

#             if not PNDealerBranch.query.filter_by(dealer_id=dealer.id, branch_id=row[2]).first():
#                 if row[2] != "NULL":
#                     branch = PNBranch.query.filter_by(id=row[2]).first()
#                     if not branch:
#                         branch = PNBranch(id=row[2], name="unknown")
#                         db.session.add(branch)
#                         db.session.commit()

#                     db.session.add(PNDealerBranch(dealer_id=dealer.id, branch_id=branch.id))
#                     db.session.commit()



