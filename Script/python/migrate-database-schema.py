import subprocess
import sys
from pathlib import Path

SQLPACKAGE = "sqlpackage"
DUMP_DIR = Path("/python/dump")
DUMP_DIR.mkdir(exist_ok=True)

SERVER_A = "macf-fcdbmaf"
SERVER_B = "sandbox-db19"
# SERVER_C = "uat-dbfcmaf"

DB_NAME = "FC_PAYMENT_MAF"
USER = "mntr"
PASSWORD = "Password009"

dacpac_file = DUMP_DIR / f"{DB_NAME}.dacpac"

def run(cmd):
    print("▶", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)
    print("✔ Done")

# 🔒 READ-ONLY EXTRACT (SAFE)
run([
    SQLPACKAGE,
    "/Action:Extract",
    f"/SourceConnectionString:Server={SERVER_A};"
    f"Database={DB_NAME};"
    f"User Id={USER};"
    f"Password={PASSWORD};"
    "Encrypt=True;"
    "TrustServerCertificate=True;",
    f"/TargetFile:{dacpac_file}",
    "/p:ExtractAllTableData=false"

    #SQLPACKAGE,
    #"/Action:Extract",
    #f"/SourceServerName:{SERVER_A}",
    #f"/SourceDatabaseName:{DB_NAME}",
    #f"/SourceUser:{USER}",
    #f"/SourcePassword:{PASSWORD}",
    #f"/TargetFile:{dacpac_file}",
    #"/p:ExtractAllTableData=false",
    #"/p:TrustServerCertificate=true",
    # "/p:IgnoreUserSettingsObjects=true",
    #"/p:IgnorePermissions=true"
])

# ⛔ No write actions executed on Server A after this point

# Publish to Server B
run([
    SQLPACKAGE,
    "/Action:Publish",
    f"/SourceFile:{dacpac_file}",
    f"/TargetConnectionString:Server={SERVER_B};"
    f"Database={DB_NAME};"
    f"User Id={USER};"
    f"Password={PASSWORD};"
    "Encrypt=True;"
    "TrustServerCertificate=True;",
    "/p:BlockOnPossibleDataLoss=false",
    "/p:DropObjectsNotInSource=false",
    "/p:IgnoreSchemaOwners=true",
    "/p:IgnoreUserLoginMappings=true",
    "/p:IgnoreUserSettingsObjects=true",
    "/p:IgnorePermissions=true",
    "/p:IgnoreLoginSids=true",
    "/p:IgnoreRoleMembership=true",
    "/p:ExcludeObjectTypes=Logins;Users;RoleMembership"


    # SQLPACKAGE,
    # "/Action:Publish",
    # f"/SourceFile:{dacpac_file}",
    # f"/TargetServerName:{SERVER_B}",
    # f"/TargetDatabaseName:{DB_NAME}",
    # f"/TargetUser:{USER}",
    # f"/TargetPassword:{PASSWORD}",
    # "Encrypt=True;"
    # "TrustServerCertificate=True;",
    # "/p:BlockOnPossibleDataLoss=false",
    # "/p:TrustServerCertificate=true",
    # "/p:DropObjectsNotInSource=false"
])

# Publish to Server C
# run([
#     SQLPACKAGE,
#     "/Action:Publish",
#     f"/SourceFile:{dacpac_file}",
#     f"/TargetServerName:{SERVER_C}",
#     f"/TargetDatabaseName:{DB_NAME}",
#     f"/TargetUser:{USER}",
#     f"/TargetPassword:{PASSWORD}",
#     "/p:BlockOnPossibleDataLoss=false",
#     "/p:DropObjectsNotInSource=false"
# ])

print("🎉 Schema migration completed safely")
