@echo off
REM start D:\scripts\mail.bat
SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
ECHO %_datetime% >> D:\Log_sync_FS\Log-FS-%_datetime%.log
echo ===================================================================
echo "RSYNC FS"
attrib -s -h D:\DATA_FS\Fileshare
echo Working.......

robocopy "\\10.10.9.11\e$" "D:\DATA_FS\Fileshare" /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.zip *.7z *.db thumb /XD *.BIN /ETA /SEC >> D:\Log_sync_FS\Log-FS-%_datetime%.log
attrib -s -h D:\DATA_FS\Fileshare
 
