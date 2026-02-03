  @echo off 

   :LOOP
   ping 172.16.100.1
   IF ERRORLEVEL 1 goto RESTART
   IF ERRORLEVEL 0 goto LOOP
   :RESTART
   netsh interface set interface "Ethernet" disabled
   ping -n 5 172.16.100.1
   netsh interface set interface "Ethernet" enabled
   ping -n 15 172.16.100.1
   goto LOOP