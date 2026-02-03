@echo off
setlocal

REM Replace with your actual log file path
set "logPath=D:\Reporting-HO\FIDFPD"
set "logFiles=D:\Reporting-HO\ReportArea\Collection\Beban_Cabang_New"


REM Replace with your log file pattern  
REM set "logPatternJPG=*.JPG"                
REM set "logPatternPDF=*.PDF"
REM set "logPatternPNG=*.PNG"
REM set "logPatternJPEG=*.JPEG"
REM set "logPatternLOG=*.log"
set "logPatternXLS=*.xls"

REM Delete File *.xls in D:\Reporting-HO\FIDFPD
echo Deleting files with extension %logPatternXLS% in %logPath%
echo -----------------------------------------------------------
forfiles /P "%logPath%" /M "%logPatternXLS%" /S /D -7 /C "cmd /c echo Deleting @file & del @file /f /q"
timeout /t 5


REM Delete Empty Directory in D:\Reporting-HO\FIDFPD
for /r "%logPath%" /d %%d in (*) do (
    dir /a /b "%%d" | findstr "^" > nul
    if errorlevel 1 (
        echo %%d is empty
		rmdir "%%d"
    ) else (
        echo %%d is not empty
    )
)
REM echo Deleting files with extenstion %logPatternPDF% in %logPath%
REM echo -----------------------------------------------------------
REM forfiles /P "%logPath%" /M "%logPatternPDF%" /S /D -3 /C "cmd /c echo Deleting @file & del @file /f /q"
REM timeout /t 5
REM 
REM echo Deleting files with extenstion %logPatternPNG% in %logPath%
REM echo -----------------------------------------------------------
REM forfiles /P "%logPath%" /M "%logPatternPNG%" /S /D -3 /C "cmd /c echo Deleting @file & del @file /f /q"
REM timeout /t 5
REM 
REM echo Deleting files with extenstion %logPatternJPEG% in %logPath%
REM echo -----------------------------------------------------------
REM forfiles /P "%logPath%" /M "%logPatternJPEG%" /S /D -3 /C "cmd /c echo Deleting @file & del @file /f /q"
REM timeout /t 5
REM 
REM echo Deleting files with extenstion %logPatternLOG% in %logFiles%
REM echo -----------------------------------------------------------
REM forfiles /P "%logFiles%" /M "%logPatternLOG%" /S /D -3 /C "cmd /c echo Deleting @file & del @file /f /q"
REM timeout /t 5

endlocal
