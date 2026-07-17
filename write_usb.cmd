@echo off
:: Aero OS USB writer — elevates and runs write_usb.ps1
:: Usage: write_usb.cmd [disknumber]
set ARGS=
if not "%~1"=="" set ARGS=-DiskNumber %~1
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File','%~dp0write_usb.ps1' %ARGS%"
