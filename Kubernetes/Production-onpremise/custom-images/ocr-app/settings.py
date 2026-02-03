import os
import base64
import logging

from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_serialize import FlaskSerializeMixin
import sqlalchemy

from config import ProductionConfig, DevelopmentConfig

app = Flask(__name__, static_folder='storage')
if os.environ.get('FLASK_ENV') == 'development':
    config = DevelopmentConfig()
else:
    config = ProductionConfig()
app.config.from_object(config)

db = SQLAlchemy(app)
FlaskSerializeMixin.db = db

logger = logging.getLogger(__name__)

db_raw = sqlalchemy.create_engine(config.SQLALCHEMY_DATABASE_URI)


def customAuthorization(token):
    from models import Application

    if token and token != '':
        authorization = token.split(" ")
        if authorization[0] == "Basic":
            try:
                base64_message = base64.b64decode(str(authorization[1]))
                token_list = str(base64_message).split("'")[1].split(":")
                application = Application.query.filter_by(client=token_list[0], client_secret=token_list[1]).first()
                if application:
                    return application
            except Exception as e:
                return None
        elif authorization[0] == "MACF01":
            application = Application.query.filter_by(client_secret=authorization[1]).first()
            if application:
                return application
    return None

def loginAuthorization(token):
    from models import AccessToken

    if token and token != '':
        authorization = token.split(" ")
        if authorization[0] == "Bearer":
            try:
                access_token = AccessToken.query.filter_by(token=authorization[1]).first()
                token = AccessToken.query.filter_by(id=1).first()
                if access_token:
                    return access_token.user
            except Exception as e:
                print(e)
                return None
    return None

def syncStatus(token):
    from models import AccessToken, Partner

    if token and token != '':
        authorization = token.split(" ")
        if authorization[0] == "Bearer":
            try:
                access_token = AccessToken.query.filter_by(token=authorization[1]).first()
                if access_token:
                    partnerID = Partner.query.filter_by(user_id=access_token.user_id).first()
                    if partnerID:
                        print(partnerID.id)
                        syncSP(partnerID.id)  
                        return None
            except Exception as e:
                return None

        elif authorization[0] == "Partner":
            partnerID = Partner.query.filter_by(user_id = authorization[1]).first()
            if partnerID:
                syncSP(partnerID.id)   
                return None
    return None

def syncSP(partnerID):    
    connection = db_raw.raw_connection()
    cursor = connection.cursor()
    cursor.execute("spSyncStageStatus ?", [int(partnerID)])
    cursor.commit() 