@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_os.ps1" %*
exit /b %ERRORLEVEL%
