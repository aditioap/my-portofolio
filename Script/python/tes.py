#!/usr/bin/python
from calendar import month
import sys
from turtle import pos
#import pymssql
import mysql.connector
#import  datetime
from datetime import datetime,timedelta
import  re
from importlib import reload
import logging

# posisi = datetime.now()
# posisi = posisi - relativedelta(months=1)
# tahunbulan = posisi.strftime('%Y%m')

posisi = datetime.now()
posisi = posisi - timedelta(weeks=3)
tahunbulan = posisi.strftime('%Y%m')


print(tahunbulan)
