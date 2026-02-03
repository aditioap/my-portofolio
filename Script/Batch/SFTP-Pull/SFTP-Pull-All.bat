@echo off
REM SFTP connection details
set SFTP_HOST=192.168.3.155
set SFTP_USER=gkm
set SFTP_KEY=C:\Batch\gkm-obayar.ppk
set REMOTE_DIR_MCF=/upload/MCF
set REMOTE_DIR_MAF=/upload/MAF
set LOCAL_DIR_MCF=E:\MACF-SFTP\GKM\OBayar\upload\MCF
set LOCAL_DIR_MAF=E:\MACF-SFTP\GKM\OBayar\upload\MAF
set LOCAL_SCRIPT=C:\Batch

REM Create SFTP batch commands file
echo lcd %LOCAL_DIR_MCF% >> %LOCAL_SCRIPT%\sftp_commands.txt
echo cd %REMOTE_DIR_MCF% >> %LOCAL_SCRIPT%\sftp_commands.txt
echo mget -r * >> %LOCAL_SCRIPT%\sftp_commands.txt
echo lcd %LOCAL_DIR_MAF% >> %LOCAL_SCRIPT%\sftp_commands.txt
echo cd %REMOTE_DIR_MAF% >> %LOCAL_SCRIPT%\sftp_commands.txt
echo mget -r * >> %LOCAL_SCRIPT%\sftp_commands.txt
echo quit >> %LOCAL_SCRIPT%\sftp_commands.txt

REM Run the SFTP command using psftp.exe
psftp.exe -i %SFTP_KEY% %SFTP_USER%@%SFTP_HOST% -b sftp_commands.txt

REM Cleanup temporary SFTP command file
del %LOCAL_SCRIPT%\sftp_commands.txt
