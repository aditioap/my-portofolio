@echo off
setlocal

:: === CONFIGURE ===
set "TARGET_DIR=E:\FTP CA\CA\MAF R4\MAF 1 R4\2024"
set "DAYS=545"

echo Cleaning folders (including files) older than %DAYS% days in "%TARGET_DIR%"...
echo.

:: Delete folders (including subfolders and files) older than %DAYS% days
forfiles /p "%TARGET_DIR%" /d -%DAYS% /c "cmd /c if @isdir==TRUE echo Deleting folder: @path & rd /s /q @path"

echo.
echo Done.
endlocal
pause
