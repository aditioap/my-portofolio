@echo off
setlocal enabledelayedexpansion

REM Fixed date
set TARGET_DATE=2025-04-21

REM Output folder
set OUTPUT_DIR=downloads
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

REM List of buckets
REM set BUCKETS=allobank-maf halamandepanbukutabungan-maf kksuratnikah-maf ktp-maf ktpapplicant-maf ktpguarantor-maf ktppartner-maf nasabahttdcmo-maf nomorrumah-maf npwp-maf pasanganttdcmo-maf bpkbbelakang-maf pbbrekening-maf penghasilantambahan-maf perizinanusaha-maf pricelist-maf rangkanomesin-maf rumahdepan-maf rumahjalan-maf salaryslip-maf stnkpajak-maf tempatusahadepan-maf bpkbdepan-maf unitdepankanan-maf unitdepankiri-maf buktikepemilikianusaha-maf buktipenghasilianusaha-maf dalamrumah-maf faq fpkbelakang-maf fpkdepan-maf
set BUCKETS=allobank-maf fpkdepan-maf

REM Loop through buckets
for %%B in (%BUCKETS%) do (
    echo Downloading bucket: %%B
    curl -k -s -X GET -H "accept: */*" ^
    "https://mobile.mcf.co.id/mcf/minio-service/api/v1/Mahan/download-by-date?bucketName=%%B&targetDate=%TARGET_DATE%" ^
    -o "%OUTPUT_DIR%\%%B-%TARGET_DATE%.zip"

    if exist "%OUTPUT_DIR%\%%B-%TARGET_DATE%.zip" (
        echo   Success: %%B-%TARGET_DATE%.zip
    ) else (
        echo   Failed: %%B-%TARGET_DATE%
    )
)

echo All downloads finished.
pause
