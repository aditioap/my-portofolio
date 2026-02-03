import pyodbc

# Define the connection string
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=UAT-DBFCMCF;'       # Source server
    'DATABASE=FC_PAYMENT_MCF;'
    'UID=mntr;'
    'PWD=Password009'
)

# Test connection
cursor = conn.cursor()
cursor.execute("SELECT @@version;")
row = cursor.fetchone()
print("Connected to SQL Server version:", row[0])

# Close the connection
cursor.close()
conn.close()
