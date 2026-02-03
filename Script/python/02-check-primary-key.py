import pyodbc

# Connection parameters
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=UAT-DBFCMCF;'
    'DATABASE=FC_PAYMENT_MCF;'
    'UID=mntr;'
    'PWD=Password009'
)

cursor = conn.cursor()

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

# Dictionary to store primary keys for each table
primary_keys = {}

# Loop through each table and get primary key columns
for table in tables:
    query = f"""
    SELECT C.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS T
    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C
    ON C.CONSTRAINT_NAME = T.CONSTRAINT_NAME
    WHERE C.TABLE_NAME = '{table}' 
    AND T.CONSTRAINT_TYPE = 'PRIMARY KEY'
    """
    
    cursor.execute(query)
    pk_columns = [row.COLUMN_NAME for row in cursor.fetchall()]
    
    # Store the primary keys in the dictionary
    primary_keys[table] = pk_columns

# Close connection
cursor.close()
conn.close()

# Print the primary keys dictionary for reference
print("Primary Keys for each table:", primary_keys)
