@echo off
REM setlocal
setlocal enabledelayedexpansion

set day=%DATE:~0,2%

set month=%DATE:~3,2%

REM set YY=%DATE:~8,2%

set year=%DATE:~6,4%


set "filename=Master-Cabang.txt"

REM Get the current date
REM for /f "tokens=1-3 delims=-" %%a in ("%date%") do (
REM     set "year=%%c"
REM     set "month=%%a"
REM     set "day=%%b"
REM )

REM Format the current date
REM set "date_format=%year%-%month%-%day%"
set "subdirectory_name=FTP-NPP"
REM Read Master Cabang
for /f "usebackq delims=" %%a in ("%filename%") do (
    set "line=%%a"
	
	set "date_format=%subdirectory_name%\!line!\%year%\%month%\%day%"
    echo Line: !line!
	echo Line: !date_format!
	REM echo Line: %line%
	
	REM Create the directory
	REM mkdir "%date_format%"
	REM if %errorlevel% equ 0 (
	REM     echo Directory created: %date_format%
	REM ) else (
	REM     echo Failed to create directory: %date_format%
	REM )


)

REM set "subdirectory_name=FTP-NPP"
REM set "date_format=%subdirectory_name%\%year%\%month%\%day%"

REM Create the directory
REM mkdir "%date_format%"
REM if %errorlevel% equ 0 (
REM     echo Directory created: %date_format%
REM ) else (
REM     echo Failed to create directory: %date_format%
REM )

endlocal