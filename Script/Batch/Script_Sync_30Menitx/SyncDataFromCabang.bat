SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%
ECHO Date: %DATE% 
ECHO Time: %TIME%  
ECHO %_datetime%
REM ===========Sync From Cabang Bekasi&Cideng to SVR-WTC==============
robocopy \\svr-bks\d$\CCAPPS\Data_Central \\svr-wtc\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Bekasi-to-WTC-%_datetime%.log
robocopy \\svr-dmg\d$\CCAPPS\Data_Central \\svr-wtc\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-Cideng-to-WTC-%_datetime%.log
robocopy \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Bekasi-to-WTC-%_datetime%.log
robocopy \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-Bekasi-to-WTC-%_datetime%.log
REM ===========Sync From SVR-WTC to Cabang Bekasi&Cideng==============
robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-bks\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Bekasi-%_datetime%.log
robocopy \\svr-wtc\d$\CCAPPS\Data_Central \\svr-dmg\d$\CCAPPS\Data_Central /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_DataCentral-WTC-to-Cideng-%_datetime%.log
robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-bks\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-WTC-to-Bekasi-%_datetime%.log
robocopy \\svr-wtc\d$\CCAPPS\REKAP_MEMO_2020 \\svr-dmg\d$\CCAPPS\REKAP_MEMO_2020 /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:C:\Temp-log-CentralCredit\Log\Log-Sync_RekapMemo-WTC-to-Cideng-%_datetime%.log

:eof
exit