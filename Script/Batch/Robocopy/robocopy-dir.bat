@echo off
REM setlocal
REM setlocal enabledelayedexpansion

set _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%

set day=%DATE:~0,2%

set month=%DATE:~3,2%

set year=%DATE:~6,4%

REM Production Config
REM set source_folder=D:\Reporting-HO
REM set date_format=%year%%month%
REM set destination_folder=F:\Backup-Reporting-HO

REM Testing Config
set source_folder=D:\MAF
set date_format=%year%%month%
set destination_folder=D:\TestCopy\%date_format%

if not exist "%destination_folder%" (
    rem echo Directory does not exist.
    rem Add commands here to create the directory if needed.
	mkdir "%destination_folder%" > nul && (
	REM robocopy %source_folder% %destination_folder% /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%_datetime%.log
	robocopy "%source_folder%" "%destination_folder%" /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%date_format%.log
	)
) else (
    rem echo Directory exists.
    rem Add commands here to handle the existing directory.
	robocopy "%source_folder%" "%destination_folder%" /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%date_format%.log
	
)

REM pause




REM for /R "%source_folder%" %%G in (*) do (
REM     set "line=%%G"
REM 	
REM 	REM set "date_format=%subdirectory_name%\!line!\%year%\%month%\%day%"
REM     echo Line: !line!
REM 	REM echo Line: !date_format!
REM 	REM echo Line: %line%
REM 	REM timeout /t 100
REM 	
REM 	
REM 	REM Create the directory
REM 	REM mkdir "%date_format%"
REM 	REM if %errorlevel% equ 0 (
REM 	REM     echo Directory created: %date_format%
REM 	REM ) else (
REM 	REM     echo Failed to create directory: %date_format%
REM 	REM )
REM 	
REM 	if not exist "%destination_folder%" (
REM         rem echo Directory does not exist.
REM         rem Add commands here to create the directory if needed.
REM     	mkdir "%destination_folder%" && (
REM     	robocopy !line! %destination_folder% /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%_datetime%.log
REM     	)
REM     ) else (
REM         rem echo Directory exists.
REM         rem Add commands here to handle the existing directory.
REM     	robocopy "!line!" "%destination_folder%" /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%_datetime%.log
REM     	
REM     )
REM 
REM 
REM )



REM set directory=C:\path\to\directory


REM robocopy "%source_folder%" "%destination_folder%" /E /SECFIX /XO /MIR /R:0 /W:0 /XF *.inf *.dll *.sys *.db thumb /XD *.BIN /ETA /SEC /LOG:D:\Log\Log-Reporting-HO-%_datetime%.log


REM endlocal