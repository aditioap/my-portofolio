@echo off
SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
echo Warning jangan klos scipts ini !!!!!
@ECHO. #REM start D:\scripts\RSYNC-NAS.bat
start D:\scripts\RSYNC-FS.bat
exit