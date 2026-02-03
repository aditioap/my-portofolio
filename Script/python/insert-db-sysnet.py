#!/usr/bin/python

from datetime import datetime
from genericpath import exists
from sqlite3 import Cursor
from time import strptime
import mysql.connector
import re
import sys
import datetime

def insert_varibles_into_table(ip_client,url,ip_server,date):


        try:
            connection = mysql.connector.connect(host='172.16.100.253',
                                         database='monitoring_efin_sysnet',
                                         user='sysadmin',
                                         password='Usr4dmServer!')

            cursor = connection.cursor()
            mySql_insert_query = """insert into user_activity(ip_client,url,ip_server,date)
                                    VALUES (%s,%s,%s,%s) """

            record = (ip_client,url,ip_server,date)
            #print(record)
            cursor.execute(mySql_insert_query, record)
            connection.commit()
            print("Record inserted successfully into Table user_activity monitoring_efin_sysnet")

        except mysql.connector.Error as error:
            print("Failed to insert into MySQL table {}".format(error))

        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                print("MySQL connection is closed")


with open("/tmp/user-activity.txt") as fp:
#with open("/tmp/test-log.txt") as fp:
    Lines = fp.readlines()
    for line in Lines:
        str_list = line.split()
        #print(str_list)
        #length = len(str_list)
        #print(length)
        ip_client=str_list[0]
        url=str_list[1]
        ip_server=str_list[2]
        date=str_list[3]

        insert_varibles_into_table(ip_client,url,ip_server,date)


        break