@echo off
set source_folder=C:\path\to\source\folder
set destination_folder=D:\path\to\destination\folder

robocopy "%source_folder%" "%destination_folder%" /E