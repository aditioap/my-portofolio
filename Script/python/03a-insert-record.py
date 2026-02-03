import pyodbc

# Connection parameters for both databases
source_conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=UAT-DBFCMCF;'
    'DATABASE=FC_PAYMENT_MCF;'
    'UID=mntr;'
    'PWD=Password009'
)

target_conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=UAT-DBFCMCF;'
    'DATABASE=PAYMENT;'
    'UID=mntr;'
    'PWD=Password009'
)

source_cursor = source_conn.cursor()
target_cursor = target_conn.cursor()

# List of tables to copy
tables = [
    "Dealer_Adjust_Double_Cair_Dtl", "Paket_Penjualan_Hdr", "tr_dealer_payment_detail",
    "Tr_Dealer_Payment_Header", "tr_dealer_payment_detail_history", "tr_dealer_payment_plafon_npp",
    "tr_dealer_payment_refund_admin", "tr_dealer_payment_refund_detail", "tr_dealer_payment_refund_header",
    "tr_dealer_payment_refund_provision", "tr_dealer_payment_refund_tenor", "tr_dealer_payment_subsidy",
    "tr_dealer_payment_transfer_list", "tr_residue", "log_dtl_tag_print_kwitansi", "tr_cash_receipt_materai_detail",
    "EDC_Payment_NPP", "EDC_Rekon_File", "EDC_Transactions", "Incentive_Agent_Dtl", "Incentive_Agent_Hdr",
    "Incentive_Agent_NPP", "log_error", "tr_bank_payment", "Incentive_Agent_Payment_Dtl",
    "Incentive_Agent_Payment_Hdr", "Loyalty_Agent_NPP", "Loyalty_Agent_NPP_log",
    "Mapping_Exception_Loyalty_Agent", "Mapping_Loyality_Amount", "payment_acc_type", "payment_type",
    "tr_bank_receipt", "tr_ARCard", "tr_cash_expenses", "tr_cash_receipt", "tr_cash_receipt_disc_adm",
    "tr_collection_ready_genvoucher", "tr_cashier_session", "tr_collection_ref", "tr_collection",
    "tr_deposit_slip_detail", "tr_other_fee", "tr_deposit_slip_header", "tr_penalty",
    "tr_deposit_slip_temp", "tr_deposit_slip_upload", "tr_social_fund", "tr_receipt_hist"
]

# Function to copy data from source to target
def copy_table_data(table_name):
    # Retrieve records from the source table
    source_cursor.execute(f'SELECT * FROM {table_name}')
    rows = source_cursor.fetchall()

    if not rows:
        print(f"No data found in table {table_name}.")
        return

    # Prepare insert query for target table
    columns = [column[0] for column in source_cursor.description]
    column_list = ', '.join(columns)
    placeholders = ', '.join('?' * len(columns))

    insert_query = f'INSERT INTO {table_name} ({column_list}) VALUES ({placeholders})'

    # Insert records into the target table
    for row in rows:
        try:
            target_cursor.execute(insert_query, row)
        except pyodbc.IntegrityError as e:
            # Handle the integrity error for duplicate records
            print(f"Duplicate record found in table {table_name}: {row}. Skipping...")
            continue
        except Exception as e:
            # Handle other potential errors
            print(f"Error inserting into {table_name}: {e}")
            continue
    
    target_conn.commit()  # Commit changes for this table
    print(f"Data copied for table {table_name}.")

# Iterate over each table and copy the data
for table in tables:
    copy_table_data(table)

# Clean up
source_cursor.close()
target_cursor.close()
source_conn.close()
target_conn.close()

print("Data transfer complete.")

