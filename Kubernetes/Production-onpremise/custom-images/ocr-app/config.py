MASTER_IMAGE_UPLOADS = 'storage/temp_img_folder'

class Config(object):
    """Base config, uses staging database server."""
    DEBUG = False
    TESTING = False
    DB_NAME = 'mobile'
    DB_PASS = 'Password567'
    DB_USER = 'dev'
    DB_SERVER = 'macf-dbuat'
    DB_DRIVER = 'SQL Server'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # IMAGE_UPLOADS = '\\\\ho36-w75\\Share\\upload\\Desc\\'
    IMAGE_UPLOADS = MASTER_IMAGE_UPLOADS
    IMAGE_URL = 'storage'
    SHARE_USER= 'luthfi.fattulloh'
    SHARE_PASSWORD = 'Password10'
    SHARE_DOMAIN = 'macf.co.id' 
    SHARE_FILENAME = 'DECS_'
    SHARE_PUBLICFILEPATH = 'storage//PrintedPO//'
    SHARE_FILEPATH = 'D:\\Dev\\DESCAPI\\DescSystem\\account\\storage\\PrintedPO'
    ALLOWED_IMAGE_EXTENSIONS = ["JPEG", "JPG", "PNG", "GIF"]

    # @property
    # def SQLALCHEMY_DATABASE_URI(self):         # Note: all caps
    #     return 'mysql://root:{}@127.0.0.1/{}'.format(self.DB_PASS, self.DB_NAME)
    #     return 'mssql+pyodbc://dev:Password567@macf-dbuat/mobile?driver=ODBC Driver 17 for SQL Server'

    @property
    def SQLALCHEMY_DATABASE_URI(self):         # Note: all caps
        # return 'mssql+pyodbc://dev:Password567@macf-dbuat/mobile?driver=ODBC Driver 17 for SQL Server'
        # return 'mysql://root:{}@127.0.0.1/{}'.format('luthF1', 'dtb_store_management_system')
        return 'mssql+pyodbc://{}:{}@{}/{}?driver={}'.format(self.DB_USER, self.DB_PASS, self.DB_SERVER, self.DB_NAME, self.DB_DRIVER)

class ProductionConfig(Config):
    DB_NAME = 'mobile'
    DB_PASS = 'Usr4app'
    DB_USER = 'UsrApp'
    DB_SERVER = 'macf-dbkonsol'
    DB_DRIVER = 'SQL Server'
    SHARE_USER= 'usr.desc'
    SHERE_PASSWORD = 'Password22'
    SHARE_DOMAIN = 'MACF'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # IMAGE_UPLOADS = '\\\\ho36-w75\\Share\\upload\\Desc\\'
    IMAGE_UPLOADS = MASTER_IMAGE_UPLOADS
    DEBUG = True
	
	
class DevelopmentConfig(Config):
    DB_NAME = 'mobile'
    DB_PASS = 'Password567'
    DB_USER = 'dev'
    DB_SERVER = 'macf-dbuat'
    DB_DRIVER = 'SQL Server'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # IMAGE_UPLOADS = '\\\\ho36-w75\\Share\\upload\\Desc\\'
    IMAGE_UPLOADS = MASTER_IMAGE_UPLOADS

    