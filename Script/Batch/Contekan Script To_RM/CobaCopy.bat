SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
REM Created 3d4 91, Rsync ini di design untuk copy file dan dengan umur 2 hari dari pembuatan , skip file ber extentiaon .JPG, simpan log, skip error, dan mutltiple execution.
start robocopy \\jkt-fs-svr1\e$\Central_Credit\Data Central \\svr-bks\d$\CCAPPS /E /MIR /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-bks-%_datetime%.log       

start robocopy \\jkt-fs-svr1\e$\To_RM \\svr-mdn\d$\To_RM /E /MIR /XD *.BIN /R:1 /W:0 /XF *.jpg thumbs.db *.7z *.zip /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-mdn-%_datetime%.log          


                                                   
:eof
exit