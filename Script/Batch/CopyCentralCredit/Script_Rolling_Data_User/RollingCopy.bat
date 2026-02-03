SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
REM Created 3d4 91, Rsync ini di design untuk copy file dan dengan umur 2 hari dari pembuatan , skip file ber extentiaon .JPG, simpan log, skip error, dan mutltiple execution.
REM ===========Rolling_Copy==============
start robocopy \\svr-wtc\d$\CCAPPS\WTC_To_Bekasi \\svr-bks\d$\CCAPPS\Bekasi_From_WTC /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-wtc-to-svr-bks-%_datetime%.log          
start robocopy \\svr-wtc\d$\CCAPPS\WTC_To_Cideng \\svr-dmg\d$\CCAPPS\Cideng_From_WTC /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-wtc-to-svr-dmg-%_datetime%.log          
start robocopy \\svr-bks\d$\CCAPPS\Bekasi_To_Cideng \\svr-dmg\d$\CCAPPS\Cideng_From_Bekasi /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-bks-to-svr-dmg-%_datetime%.log
start robocopy \\svr-bks\d$\CCAPPS\Bekasi_To_WTC \\svr-wtc\d$\CCAPPS\WTC_From_Bekasi /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-bks-to-svr-wtc-%_datetime%.log                                                   
start robocopy \\svr-dmg\d$\CCAPPS\Cideng_To_Bekasi \\svr-bks\d$\CCAPPS\Bekasi_From_Cideng /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-dmg-to-svr-bks-%_datetime%.log
start robocopy \\svr-dmg\d$\CCAPPS\Cideng_To_WTC \\svr-wtc\d$\CCAPPS\WTC_From_Cideng /E /MIR /RH:2200-0400 /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /XO /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\svr-dmg-to-svr-wtc-%_datetime%.log
REM ===========Copy Data_Central==============
REM start robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-dmg\d$\CCAPPS\Data_Central /E /MIR /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\Data_Central_To_Cideng-%_datetime%.log
REM start robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-bks\d$\CCAPPS\Data_Central /E /MIR /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\Data_Central_To_Bekasi-%_datetime%.log
REM ===========Copy REKAP_MEMO_2020==============
REM start robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 /E /MIR /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\REKAP_MEMO_2020_To_Bekasi-%_datetime%.log
REM start robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 /E /MIR /XD *.BIN /R:1 /W:0 /XF thumbs.db /ETA /X /LOG:C:\Temp-log-CobaCopy\Log-CCAPPS\REKAP_MEMO_2020_To_Cideng-%_datetime%.log


:eof
exit