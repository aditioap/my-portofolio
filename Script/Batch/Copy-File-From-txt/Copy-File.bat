@echo off
setlocal

set dest=\\macf-appaudit\FTP-Newzoom
set filelist-R2=E:\Script\Copy-File\file_list-R2.txt
set filelist-R4=E:\Script\Copy-File\file_list-R2.txt

for /f "delims=" %%a in (%filelist-R2%) do (
    REM copy "%%a" "%dest%"
	echo "%%a" "%dest%"
)

endlocal
