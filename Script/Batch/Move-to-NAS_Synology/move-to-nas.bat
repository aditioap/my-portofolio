@echo off
SET _datetime=%DATE:~7,2%-%DATE:~4,2%-%DATE:~10,4%

SET date_format=%year%%month%%day%

REM SET FOLDER SOURCE DAN DESTINATION NAS SYNOLOGY
REM INI CONTOH SCRIPT YA GAES!
SET "source_folder=F:\FTP ALL DEPARTMENT\Department RO\Repeat Order R2\Directory FollowUpRO\Daily"
SET "destination_folder=L:\Daily"
REM SET destination_folder="\\macf-sdcltn\Test-Aditio"
REM SET log_file="\\macf-sdcltn\Test-Aditio"
SET "log_file=L:\Log\robocopy_log.txt"

robocopy "%source_folder%" "%destination_folder%" /E /MIR /XD *.BIN /MINAGE:7 /R:0 /W:0 /XF *.jpg thumbs.db *.7z /ETA /X /LOG:%log_file%

if %errorlevel% equ 0 (

	echo Robocopy Completed Succesfully.
	forfiles /P "%source_folder%" /S /D -7 /M *.csv /C "cmd /c if @isdir==FALSE del @file" >> "%log_file%" 2>&1
	forfiles /P "%source_folder%" /S /D -7 /M *.rar /C "cmd /c if @isdir==FALSE del @file" >> "%log_file%" 2>&1
	REM forfiles /P "%source_folder%" /S /D -7 /M *.csv *.rar /C "cmd /c if @isdir==FALSE del @file"
	
	echo Deletion process completed.
	
) else (
	
	echo Robocopy encountered an error. Check the log file for details

)



pause
REM :eof
REM exit