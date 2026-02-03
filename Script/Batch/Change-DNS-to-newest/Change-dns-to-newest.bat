@echo off
setlocal

REM === Set your network adapter name ===
set adapterName=Wi-Fi

REM === Set your new primary and secondary DNS ===
set primaryDNS=172.16.100.6
set secondaryDNS=172.16.100.103

echo Changing DNS for adapter: %adapterName%

REM Replace all DNS settings with the primary DNS
netsh interface ip set dns name="%adapterName%" static %primaryDNS%

REM Add the secondary DNS as index=2
netsh interface ip add dns name="%adapterName%" %secondaryDNS% index=2

echo DNS changed to:
echo Primary: %primaryDNS%
echo Secondary: %secondaryDNS%
REM pause