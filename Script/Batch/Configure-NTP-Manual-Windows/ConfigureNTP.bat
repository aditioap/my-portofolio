@echo off
set "ntpServer=ntp_server_address"  REM Replace with the NTP server address

net start w32time

w32tm /config /manualpeerlist:%ntpServer% /syncfromflags:manual /reliable:YES /update
w32tm /resync

REM Display time synchronization status
w32tm /query /status
