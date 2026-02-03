@echo off

REM Replace with your actual log file path
set "logPath=C:\inetpub\logs\LogFiles"
set "logPathCollectionAPIv4=C:\inetpub\wwwroot\CollectionWebAPIv4\logs"

REM Replace with your log file pattern  
set "logPattern=*.log"                
set "logPatternCollection=logger.log.*"

REM Get the current date in YYYYMMDD format
for /F "usebackq tokens=*" %%A in (`powershell Get-Date -Format "yyyyMMdd"`) do set "currentDate=%%A"

REM Calculate the date one month ago (subtracting 1 from the month part)
set /A "oneMonthAgoMonth=1%currentDate:~4,2%-100"
set /A "oneMonthAgoYear=%currentDate:~0,4%-(%oneMonthAgoMonth%==1)"

REM Build the date one month ago in YYYYMMDD format
set "oneMonthAgo=%oneMonthAgoYear%%oneMonthAgoMonth%%currentDate:~6%"

REM Use forfiles to delete log files older than one month
pushd "%logPath%"
forfiles /P "." /M "%logPattern%" /S /D -%oneMonthAgo% /C "cmd /c del /q @path"
popd

pushd "%logPathCollectionAPIv4%"
forfiles /P "." /M "%logPatternCollection%" /S /D -%oneMonthAgo% /C "cmd /c del /q @path"
popd
