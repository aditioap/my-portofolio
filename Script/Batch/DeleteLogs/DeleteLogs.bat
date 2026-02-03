SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
REM Created 3d4 91, Rsync ini di design untuk copy file dan dengan umur 2 hari dari pembuatan , skip file ber extentiaon .JPG, simpan log, skip error, dan mutltiple execution.
REM start robocopy \\jkt-fs-svr1\e$\To_RM \\svr-bdg\d$\To_RM /E /MIR /XD *.BIN /R:1 /W:0 /XF *.jpg thumbs.db *.7z *.zip /ETA /X /LOG:C:\Temp-log-CobaCopy\Log\svr-bdg-%_datetime%.log       

REM C:\Users\aditio.prabowo\Downloads>forfiles /P "c:\Users\aditio.prabowo\Downloads" /S /D -30 /M *.deb /C "cmd /c del @file"
forfiles /P "F:\Log" /S /D -30 /M *.log /C "cmd /c del @file"

                                                   
:eof
exit