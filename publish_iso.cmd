@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_iso.ps1" %*
exit /b %ERRORLEVEL%
