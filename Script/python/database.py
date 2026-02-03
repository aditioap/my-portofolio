#!/usr/bin/python
import mysql.connector
import re
import sys


mydb = mysql.connector.connect (
    host="10.105.24.35",
    user="aditioap",
    passwd="P@ssw0rd"
)

mycursor = mydb.cursor()
mycursor.execute("SHOW DATABASES")
for x in mycursor:
    print(x)