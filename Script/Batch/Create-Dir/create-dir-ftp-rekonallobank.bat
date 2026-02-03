@echo off
setlocal enabledelayedexpansion

set "baseDir=E:\FTP-Allobank-Rekon\MAF\2024"

for /L %%M in (1,1,12) do (
    set "month=0%%M"
    set "month=!month:~-2!"
    mkdir "%baseDir%\!month!"
)

endlocal