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

# List of tables to update
# tables = [
#     "Dealer_Adjust_Double_Cair_Dtl", "Paket_Penjualan_Hdr", "tr_dealer_payment_detail",
#     "Tr_Dealer_Payment_Header", "tr_dealer_payment_detail_history", "tr_dealer_payment_plafon_npp",
#     "tr_dealer_payment_refund_admin", "tr_dealer_payment_refund_detail", "tr_dealer_payment_refund_header",
#     "tr_dealer_payment_refund_provision", "tr_dealer_payment_refund_tenor", "tr_dealer_payment_subsidy",
#     "tr_dealer_payment_transfer_list", "tr_residue", "log_dtl_tag_print_kwitansi", "tr_cash_receipt_materai_detail",
#     "EDC_Payment_NPP", "EDC_Rekon_File", "EDC_Transactions", "Incentive_Agent_Dtl", "Incentive_Agent_Hdr",
#     "Incentive_Agent_NPP", "log_error", "tr_bank_payment", "Incentive_Agent_Payment_Dtl",
#     "Incentive_Agent_Payment_Hdr", "Loyalty_Agent_NPP", "Loyalty_Agent_NPP_log",
#     "Mapping_Exception_Loyalty_Agent", "Mapping_Loyality_Amount", "payment_acc_type", "payment_type",
#     "tr_bank_receipt", "tr_ARCard", "tr_cash_expenses", "tr_cash_receipt", "tr_cash_receipt_disc_adm",
#     "tr_collection_ready_genvoucher", "tr_cashier_session", "tr_collection_ref", "tr_collection",
#     "tr_deposit_slip_detail", "tr_other_fee", "tr_deposit_slip_header", "tr_penalty",
#     "tr_deposit_slip_temp", "tr_deposit_slip_upload", "tr_social_fund", "tr_receipt_hist"
# ]

tables = ["tr_collection"]

def get_primary_key(cursor, table):
    """Get the primary key column(s) for a table."""
    cursor.execute(f"""
        SELECT COLUMN_NAME 
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
        WHERE TABLE_NAME = '{table}' AND CONSTRAINT_NAME IN (
            SELECT CONSTRAINT_NAME 
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME = '{table}' AND CONSTRAINT_TYPE = 'PRIMARY KEY'
        )
    """)
    return [row[0] for row in cursor.fetchall()]

# Update records for each table
for table in tables:
    # Get the primary key(s) for the current table
    primary_keys = get_primary_key(source_cursor, table)

    # Fetch all records from the source table
    source_cursor.execute(f"SELECT * FROM {table}")
    source_records = source_cursor.fetchall()
    source_columns = [column[0] for column in source_cursor.description]

    for record in source_records:
        # Create a WHERE clause based on primary keys (or use all columns if none found)
        if primary_keys:
            where_clause = " AND ".join([f"{pk} = ?" for pk in primary_keys])
            where_values = [record[source_columns.index(pk)] for pk in primary_keys]
        else:
            # If no primary key, use all columns to identify the row
            where_clause = " AND ".join([f"{col} = ?" for col in source_columns])
            where_values = record

        # Fetch the corresponding record from the target table
        target_cursor.execute(f"SELECT * FROM {table} WHERE {where_clause}", *where_values)
        target_record = target_cursor.fetchone()

        # If the target record exists, compare it with the source record
        if target_record:
            updates = []
            update_values = []  # Create a list to hold update values

            for col, source_value, target_value in zip(source_columns, record, target_record):
                if source_value != target_value:
                    updates.append(f"{col} = ?")
                    update_values.append(source_value)  # Collect the source value for the update

            # If there are updates, construct the update query
            if updates:
                set_clause = ', '.join(updates)
                update_query = f"UPDATE {table} SET {set_clause} WHERE {where_clause}"
                update_values.extend(where_values)  # Add where values to the update values

                # Check if update_values length matches the number of placeholders
                if len(update_values) == len(updates) + len(where_values):
                    target_cursor.execute(update_query, *update_values)
                    print(f"Updated record in table: {table}, where: {where_values}")
                else:
                    print(f"Parameter mismatch for table: {table}. Expected {len(updates) + len(where_values)} but got {len(update_values)}.")

    # Commit the changes for the current table
    target_conn.commit()


# Close the cursors and connections
source_cursor.close()
target_cursor.close()
source_conn.close()
target_conn.close()

