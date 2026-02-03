#!/usr/bin/python
import sys
#import pymssql
import mysql.connector
import  datetime
import  re
from importlib import reload

config_db_testA = {
    'user'              : 'aditioap',
    'password'          : 'P@ssw0rd',
    'host'              : '10.105.24.35',
    'port'              : '3306',
    'database'          : 'testA',
    'raise_on_warnings' : True,
}

config_db_testB = {
    'user'              : 'aditioap',
    'password'          : 'P@ssw0rd',
    'host'              : '10.105.24.35',
    'database'          : 'testB',
    'raise_on_warnings' : True,
}

### Baru sampe sini kalo mau edit ###
def main(argv):
    try:
        print ('======= '+str(datetime.datetime.now())+' START Tes Summary =========')
        
        #cnx_nds_slave = mysql.connector.connect(**config_nds_slave)
        #cur_nds_slave = cnx_nds_slave.cursor(buffered=True)
        cnx_
        
        cnx_dao = mysql.connector.connect(**config_dao)
        cur_dao = cnx_dao.cursor(buffered=True)
        
        # nds summary H-1
        # SALES_VOLUME: get tanggal_transaksi dan sales volume
        print('START NDS FITUR SUMMARY')
        
        cur_nds_slave.execute(
            """SELECT 
                    DATE(a.tanggal_trx) AS tanggal, a.func_id, b.tran_desc, 
                    COUNT(*) AS jumlah_transkasi, '' AS sales_volume, '' AS fee, flag_monetary
                FROM ej_temp a
                JOIN setup b 
                    ON a.func_id = b.tran_code
                WHERE 
                    b.flag_monetary = 'N'
                    AND func_id IN ('2422', '4077', '2424')
                GROUP BY 2, 1
                UNION
                SELECT 
                    DATE(a.tanggal_trx) AS tanggal, a.func_id, b.tran_desc, 
                    COUNT(*) as jumlah, ROUND(SUM((a.nominal_debit+a.nominal_kredit+a.nominal_fee)/2 - a.nominal_fee), 0) AS sales_volume, SUM(nominal_fee) AS fee, flag_monetary
                FROM ej_temp a
                JOIN setup b 
                    ON a.func_id = b.tran_code
                WHERE 
                    b.flag_monetary = 'Y'
                    AND a.func_id IN ('2302', '1302', '2123')
                GROUP BY 2, 1
        """)
        
        nds_slave_result = cur_nds_slave.fetchall()

        for nds_slave in nds_slave_result:
            print("""
                INSERT INTO nds_summary.nds_fitur_summary 
                (
                    tanggal_transaksi,
                    func_id,
                    func_desc,
                    jumlah_transaksi,                    
                    sales_volume,
                    fee,
                    flag_monetary
                ) VALUES 
                ('"""+sales_volume[0].strftime('%Y-%m-%d')+"""',"""
                +str(sales_volume[1])+""","""
                +str(sales_volume[2])+""","""
                +str(sales_volume[3])+""","""
                +str(sales_volume[4])+""","""
                +str(sales_volume[5])+""","""
                +str(sales_volume[6])+""")"""
            )
            break

        #cnx_dao.commit()
        
            # cur_dao.execute print ("""
            #     INSERT INTO nds_summary.harian_summary 
            #  (
            #      tanggal_transaksi, 
            #      sales_volume
            #  ) VALUES 
            # ('"""+sales_volume[0].strftime('%Y-%m-%d')+"""',"""
            # +str(sales_volume[1])+""")"""
            # )
            # break

        print('END NDS FITUR SUMMARY')
        
        print ('======= '+str(datetime.datetime.now())+' FINISH NDS FITUR Summary =========\n')

    except (Exception) as err:
        print(err)

        sys.exit(2)
    finally:
        cur_nds_slave.close()
        cnx_nds_slave.close()
        cur_dao.close()
        cnx_dao.close()
		
if __name__ == "__main__":
	main(sys.argv[1:])