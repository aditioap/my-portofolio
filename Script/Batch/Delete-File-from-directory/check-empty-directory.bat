@echo off
set "directory=D:\tes"

REM dir /a /b "%directory%" | findstr "^" > nul
REM if errorlevel 1 (
REM     echo Directory is empty
REM ) else (
REM     echo Directory is not empty
REM )


for /r "%directory%" /d %%d in (*) do (
    dir /a /b "%%d" | findstr "^" > nul
    if errorlevel 1 (
        echo %%d is empty
		rmdir "%%d"
    ) else (
        echo %%d is not empty
    )
)
