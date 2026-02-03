import mysql.connector

try:
    connection = mysql.connector.connect(host='172.16.100.253',
                                         database='monitoring_efin_sysnet',
                                         user='sysadmin',
                                         password='Usr4dmServer!')

    cursor = connection.cursor()   
    
    mySql_insert_query = """INSERT INTO user_activity (ip_client, url, ip_server, date) 
                           VALUES 
                           (%s, %s, %s, %s) """
    count = 0
    with open('/tmp/test-log.txt') as f:
         reader = f.readlines()
         for i in reader:
             #count += 1
             #print(i)
             cursor.execute(mySql_insert_query, i)



    

    #cursor = connection.cursor()
    
    connection.commit()
    print(cursor.rowcount, "Record inserted successfully into user_activity")
    cursor.close()

except mysql.connector.Error as error:
    print("Failed to insert record into user_activity table {}".format(error))

finally:
    if connection.is_connected():
        connection.close()
        print("MySQL connection is closed")