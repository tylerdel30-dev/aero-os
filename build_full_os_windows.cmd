@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_full_os_windows.ps1" %*
