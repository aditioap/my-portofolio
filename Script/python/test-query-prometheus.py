#from prometheus_api_client import PrometheusConnect
import requests
from prometheus_api_client import PrometheusConnect
from prometheus_client.parser import text_string_to_metric_families

import mysql.connector

# Prometheus Configuration
prometheus_url = "http://api-fincore.mcf.co.id:9090"
prometheus = PrometheusConnect(url=prometheus_url)
# prometheus_query = 'count(container_last_seen{name=~"$name",instance=~"$instance",image!=""}) by (instance)'

# MySQL Configuration
# mysql_host = "your_mysql_host"
# mysql_user = "your_mysql_user"
# mysql_password = "your_mysql_password"
# mysql_db = "your_mysql_database"

# Connect to MySQL
# conn = mysql.connector.connect(
#     host=mysql_host,
#     user=mysql_user,
#     password=mysql_password,
#     database=mysql_db
# )
# cursor = conn.cursor()

# Fetch Prometheus Data
# query = 'machine_cpu_cores{instance="10.0.4.8:9091",job="cadvisor"}'
query = 'sum(machine_cpu_cores{instance=~"10.0.4.*:9091",job="cadvisor"}) by (instance,value)'
# query = 'sum(irate(container_cpu_user_seconds_total{name=~"FIN-*",instance=~"10.0.4.*:9091",image!=""}[5m]) * 100)by (instance) / sum(machine_cpu_cores{instance=~"10.0.4.*:9091"}) by (instance)'
data = prometheus.custom_query(query)
# Fetch Prometheus Data
#response = requests.get(prometheus_url + '/api/v1/query', params={'query': prometheus_query})
# response = requests.get(prometheus_url, params={'query': prometheus_query})
# data = response.json()['data']['result']

# data = prometheus.custom_query(query)
# print(data)

# Store data in MySQL
for result in data:
    print(result)
    # Parse and process the Prometheus data if needed
    # Insert data into MySQL
    # cursor.execute('INSERT INTO your_table_name (column1, column2, ...) VALUES (%s, %s, ...)', (result['value1'], result['value2'], ...))
    # conn.commit()

# # Close the connection
# cursor.close()
# conn.close()
