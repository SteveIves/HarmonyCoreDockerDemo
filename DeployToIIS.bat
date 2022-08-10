@echo off

openfiles >nul 2>&1
if ERRORLEVEL 1 (
  echo ERROR: This batch file requires elevated privileges. Please use "Run as Administrator".
  goto :eof
)

if not exist "%ProgramW6432%\7-Zip\7z.exe" (
  echo ERROR: 7-Zip is not installed!
  goto :eof
)

setlocal

rem If we have a settings file, execute it
set SCRIPT_DIR=%~dp0
if exist "%SCRIPT_DIR%DeployToIIS.Settings.bat" call "%SCRIPT_DIR%DeployToIIS.Settings.bat"

rem Do we have an IIS application directory?
if not defined IIS_APP_DIR (
    echo ERROR: Unable to continue because environment variable in IIS_APP_DIR is not set!
    goto :done_endlocal
)

rem Does the IIS application directory exist?
if not exist "%IIS_APP_DIR%\." (
    echo ERROR: Unable to continue because the IIS application directory %IIS_APP_DIR% does not exist!
    goto :done_endlocal
)

rem Do we have an IIS site name?
if not defined IIS_SITE_NAME (
    echo ERROR: Unable to continue because environment variable in IIS_SITE_NAME is not set!
    goto :done_endlocal
)

rem Do we have an IIS application pool name?
if not defined IIS_APP_POOL_NAME (
    echo ERROR: Unable to continue because environment variable in IIS_APP_POOL_NAME is not set!
    goto :done_endlocal
)

pushd "%IIS_APP_DIR%"

if "%~1%"=="" (
  rem No command line parameter
  for %%f in (HarmonyCoreService*.zip) do set fileExist=1
  if defined fileExist (
    for /F "delims=" %%f in ('dir /b *.zip') do set zipFileName=%%f
  ) else (
    echo ERROR: No deployment zip files found!
    goto fail
  )
) else (
  rem We have a command line parameter
  if exist "%~1" (
    set zipFileName=%1
  ) else (
    echo ERROR: Zip file %1 not found!
    goto fail
  )
)

echo Deploying zip file %zipFileName%

:confirm
  set /p answer=Continue (Y/N)? 
  if /i "%answer:~,1%" EQU "Y" goto do_deploy
  if /i "%answer:~,1%" EQU "N" goto done_popd_endlocal
  goto confirm

:do_deploy

echo Stopping IIS Application Pool
%WINDIR%\System32\inetsrv\appcmd.exe stop site /site.name:"%IIS_SITE_NAME%"

echo Stopping IIS Web Site
%WINDIR%\System32\inetsrv\appcmd.exe stop apppool /apppool.name:"%IIS_APP_POOL_NAME%"

echo Deleting existing files

rem Delete all files except *.zip in the current directory and all subdirectories
for /R "." %%f in (*) do (if not "%%~xf"==".zip" del "%%~f")

rem Delete all subdirectories
for /D %%d in (*) do rmdir /S /Q %%d

rem All that should be left now is ZIP files!

echo Extracting files from zip file

"%ProgramW6432%\7-Zip\7z.exe" x -y %zipFileName%

if ERRORLEVEL 0 (
  echo Files extracted successfully
  echo Restarting IIS Web Site
  %WINDIR%\System32\inetsrv\appcmd.exe start apppool /apppool.name:"%IIS_APP_POOL_NAME%"
  echo Restarting IIS Application Pool
  %WINDIR%\System32\inetsrv\appcmd.exe start site /site.name:"%IIS_SITE_NAME%"
) else (
  echo ERROR: Error during file extraction, web site and application pool will NOT be restarted!
  goto fail
)

goto done_popd_endlocal

:fail
popd
endlocal 
pause
exit /B 1

:done_popd_endlocal
popd

:done_endlocal
endlocal
