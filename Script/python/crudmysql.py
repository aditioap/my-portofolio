#!/usr/bin/python

from datetime import datetime
from genericpath import exists
from sqlite3 import Cursor
from time import strptime
import mysql.connector
import re
import sys
import datetime


mydb_A = mysql.connector.connect (
    host="10.105.24.35",
    user="aditioap",
    passwd="P@ssw0rd",
    database="testA"
)

mycursor_A = mydb_A.cursor()
mycursor_A.execute("select * from audits")

## Function Insert
def insert_varibles_into_table(id,handle,transactionid,description,audit,time,action):


        try:
            connection = mysql.connector.connect(host="10.105.24.35",
                                                user="aditioap",
                                                passwd="P@ssw0rd",
                                                database="testB")
            cursor = connection.cursor()
            mySql_insert_query = """insert into audits(id,handle,transactionid,description,audit,time,action)
                                    VALUES (%s,%s,%s,%s,%s,%s,%s) """

            record = (id,handle,transactionid,description,audit,time,action)
            #print(record)
            cursor.execute(mySql_insert_query, record)
            connection.commit()
            print("Record inserted successfully into Table Audits TestB")

        except mysql.connector.Error as error:
            print("Failed to insert into MySQL table {}".format(error))

        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                print("MySQL connection is closed")

def insert_records_if_not_exists (id,handle,transactionid,description,audit,time,action):


        try:
            connection = mysql.connector.connect(host="10.105.24.35",
                                                user="aditioap",
                                                passwd="P@ssw0rd",
                                                database="testB")
            cursor = connection.cursor()

            ## Query Insert ##
            mysql_insert_query = """
                    insert into audits(id,handle,transactionid,description,audit,time,action)
                                    VALUES (%s,%s,%s,%s,%s,%s,%s) 
            
            """
            
            ## Validasi Check Record Exist ##
            cursor.execute("""
            select exists(select * from audits where id = {id})
            """.format(id = id,handle = handle,transactionid = transactionid,description = description,audit = audit,time = time,action = action))
            check_record = cursor.fetchall()
            record = (id,handle,transactionid,description,audit,time,action)

            for z in check_record:
                value_cek=int(z[0])
                #print(value_cek)
                
                ## Insert Record kl gak ada datanya di table tujuan ##
                if value_cek < 1:
                    cursor.execute(mysql_insert_query, record)
                    #print(record)
                    connection.commit()
                    print("Record inserted successfully into Table Audits TestB")
                else:
                    pass
                

        except mysql.connector.Error as error:
            print("Failed to insert into MySQL table {}".format(error))

        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                print("MySQL connection is closed")



for x in mycursor_A.fetchall():
    id=x[0]
    handle=x[1]
    transactionid=x[2]
    description=x[3]
    audit=x[4]
    time=str(x[5])
    action=x[6]

    #insert_varibles_into_table(id,handle,transactionid,description,audit,time,action)
    insert_records_if_not_exists(id,handle,transactionid,description,audit,time,action)
    #break










