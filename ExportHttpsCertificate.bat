@echo off
setlocal

rem If we have a settings file, execute it
if exist ExportHttpsCertificate.Settings.bat call ExportHttpsCertificate.Settings.bat

dotnet dev-certs https -ep %USERPROFILE%\.aspnet\https\Services.Host.pfx -p p@ssw0rd

dotnet dev-certs https --trust

if not exist %WSL_CERT_LOCATION% mkdir %WSL_CERT_LOCATION%

copy /y %USERPROFILE%\.aspnet\https\Services.Host.pfx %WSL_CERT_LOCATION%

endlocal
