  @echo off 

   :LOOP
   ping 10.50.1.1
   IF ERRORLEVEL 1 goto RESTART
   IF ERRORLEVEL 0 goto LOOP
   :RESTART
   netsh interface set interface "VirtualBox Host-Only Network" disabled
   ping -n 5 10.50.1.1
   netsh interface set interface "VirtualBox Host-Only Network" enabled
   ping -n 15 10.50.1.1
   goto LOOP