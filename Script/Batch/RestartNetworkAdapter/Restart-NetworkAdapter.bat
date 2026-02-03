  @echo off 
   set adapter_name="Ethernet Instance 0 3" 
   REM Ini mesti diganti sesuai nama interface
   REM cara cek nya buka cmd terus execute command "netsh interface show interface"
   

   :LOOP
   ping -n 10 172.16.100.1 |findstr "TTL="
   
   IF %errorlevel% NEQ 0 (
		goto RESTART
   
   ) else (
		goto LOOP
   )

   
   :RESTART
   for /f "tokens=1-3 delims=:." %%a in ("%TIME%") do (
	 set "HH=0%%a"
	 set "MM=0%%b"
	 set "ss=0%%c"
   )
   set "HH=%HH:~-2%"
   set "MM=%MM:~-2%"
   set "ss=%ss:~-2%"
   set "datetime=%date%_%HH%:%MM%:%ss%"
   echo %datetime%
   
   
   echo %adapter_name% disconnect, process restarting... >> D:\Logs\Log-Restart-Adapter.log
   netsh interface set interface %adapter_name% admin=disable
   ping -n 5 172.16.100.1 |findstr "TTL="
   netsh interface set interface %adapter_name% admin=enable
   echo %adapter_name% connected on %datetime%, process restarting Success... >> D:\Logs\Log-Restart-Adapter.log
   ping -n 15 172.16.100.1 |findstr "TTL="
   
   goto LOOP