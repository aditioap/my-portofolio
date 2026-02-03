@echo off
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%"

robocopy E:\ "Z:\Backup-svr\Daily\file-share-incremental\Daily-%datestamp%" /s /w:0 /r:0 /ETA /MAXAGE:1 /XD *.BIN /R:0 /W:0 /XO /XF *.jpg thumbs.db *.7z *.zip /LOG:C:\bkp-scripts\Log-bkp_incremental\Bkp_incremental-%datestamp%.log
attrib -s -h Z:\Backup-svr\Daily\file-share-incremental\Daily-%datestamp%
start C:\bkp-scripts\Ratensi.bat
:eof
exit
rem create by ade purnomo



