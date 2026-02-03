import subprocess
from pathlib import Path

SRC_SERVER = "MCF-MOBDB"
DST_SERVER = "SANDBOX-DB22"
DB_NAME = "mob_acq"
USER = "mntr"
PASSWORD = "Password009"
SP_NAME = "dbo.trace_ggh"

OUT_FILE = Path("/tmp/trace_ggh.sql")


def run(cmd):
    subprocess.run(cmd, check=True)


print("▶ Extracting stored procedure from source...")

run([
    "sqlcmd",
    "-S", SRC_SERVER,
    "-d", DB_NAME,
    "-U", USER,
    "-P", PASSWORD,
    "-C",
    "-h", "-1",
    "-W",
    "-Q",
    f"""
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    SELECT @sql = definition
    FROM sys.sql_modules
    WHERE object_id = OBJECT_ID('{SP_NAME}');

    SET @sql = STUFF(
        @sql,
        1,
        CHARINDEX('PROCEDURE', @sql) + LEN('PROCEDURE') - 1,
        'CREATE OR ALTER PROCEDURE'
    );

    SELECT @sql;
    """,
    "-o", str(OUT_FILE)
])

print(f"✔ Stored procedure saved to {OUT_FILE}")

print("▶ Deploying stored procedure to destination...")

run([
    "sqlcmd",
    "-S", DST_SERVER,
    "-d", DB_NAME,
    "-U", USER,
    "-P", PASSWORD,
    "-C",
    "-i", str(OUT_FILE)
])

print("✅ Stored procedure created/updated successfully")
