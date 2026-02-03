SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
REM ===========Sync From Cabang Bekasi&Cideng to SVR-WTC==============
start robocopy \\svr-bks\d$\CCAPPS\Data_Central \\svr-wtc\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Bekasi-to-WTC-%_datetime%.log
start robocopy \\svr-dmg\d$\CCAPPS\Data_Central \\svr-wtc\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Cideng-to-WTC-%_datetime%.log
start robocopy \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Bekasi-to-WTC-%_datetime%.log
start robocopy \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Bekasi-to-WTC-%_datetime%.log
REM ===========Sync From SVR-WTC to Cabang Bekasi&Cideng==============
start robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-bks\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Bekasi-%_datetime%.log
start robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-dmg\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log
start robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-WTC-to-Bekasi-%_datetime%.log
start robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-WTC-to-Cideng-%_datetime%.log
REM ===========Sync From Bekasi <-----> Cideng==============
REM start robocopy \\svr-bks\d$\CCAPPS\Bekasi_To_Cideng \\svr-dmg\d$\CCAPPS\Cideng_From_Bekasi /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log
REM start robocopy \\svr-bks\d$\CCAPPS\Bekasi_To_WTC \\svr-wtc\d$\CCAPPS\WTC_From_Bekasi /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log                                                   
REM start robocopy \\svr-dmg\d$\CCAPPS\Cideng_To_Bekasi \\svr-bks\d$\CCAPPS\Bekasi_From_Cideng /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log
REM start robocopy \\svr-dmg\d$\CCAPPS\Cideng_To_WTC \\svr-wtc\d$\CCAPPS\WTC_From_Cideng /SECFIX /XO /MIR /R:0 /W:0 /ipg:833 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log
start robocopy \\svr-bks\d$\CCAPPS\Data_Central \\svr-dmg\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Bekasi-to-Cideng-%_datetime%.log
start robocopy \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Bekasi-to-Cideng-%_datetime%.log
start robocopy \\svr-dmg\d$\CCAPPS\Data_Central \\svr-bks\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Cideng-to-Bekasi-%_datetime%.log
start robocopy \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /ipg:1750 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Cideng-to-Bekasi-%_datetime%.log
:eof
exit