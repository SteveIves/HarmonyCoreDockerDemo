@echo off

if /i "%1" == "SETUP" goto continue
if /i "%1" == "UPDATE" goto continue

echo.
echo Usage: SendToVMS mode
echo.
echo  Where mode is one of:
echo.
echo    SETUP  Create required VMS directories and upload files
echo    UPDATE Upload latest local files to VMS
echo.
echo To provide configuration information for this procedure, create a file
echo named SendToVMS.Settings.bat in the same folder, and set the environment
echo variables shown in the example below:
echo. 
echo   @echo off
echo   set VMS_HOST=10.1.1.1
echo   set VMS_USER=bridge
echo   set VMS_PASSWORD=p@ssw0rd
echo. 
echo This procedure will search for that file and execute it if present.
echo Because the settings file contains sensitive information you shold
echo NOT add it to your version control environment.
echo.
goto :eof

:continue

setlocal
pushd %~dp0

if exist SendToVMS.Settings.bat call SendToVMS.Settings.bat

rem 
rem =============================================================================
rem
rem Create an FTP command script to transfer the files
rem 
echo Creating FTP script...
echo open %VMS_HOST% 21 > ftp.tmp
echo %VMS_USER% >> ftp.tmp
echo %VMS_PASSWORD% >> ftp.tmp
echo ascii >> ftp.tmp
echo prompt >> ftp.tmp

if /i "%1" == "SETUP" (
  echo mkdir [.OBJ] >> ftp.tmp
  echo mkdir [.PROTO] >> ftp.tmp
  echo mkdir [.REPOSITORY] >> ftp.tmp
  echo mkdir [.SOURCE] >> ftp.tmp
  echo mkdir [.SOURCE.BRIDGE] >> ftp.tmp
  echo mkdir [.SOURCE.DISPATCHERS] >> ftp.tmp
  echo mkdir [.SOURCE.METHODS] >> ftp.tmp
  echo mkdir [.SOURCE.MODELS] >> ftp.tmp
  echo mkdir [.SOURCE.STUBS] >> ftp.tmp
)

echo cd [.REPOSITORY] >> ftp.tmp
echo mput ..\..\repository\repository.scm >> ftp.tmp
echo cd [-.SOURCE] >> ftp.tmp
echo mput ..\source\host.dbl >> ftp.tmp
echo cd [.BRIDGE] >> ftp.tmp
echo mput ..\source\bridge\*.dbl >> ftp.tmp
echo cd [-.DISPATCHERS] >> ftp.tmp
echo mput ..\source\dispatchers\*.dbl >> ftp.tmp
echo cd [-.METHODS] >> ftp.tmp
echo mput ..\source\methods\*.dbl >> ftp.tmp
echo cd [-.MODELS] >> ftp.tmp
echo mput ..\source\models\*.dbl >> ftp.tmp
echo cd [-.-] >> ftp.tmp
echo put BRIDGE.OPT >> ftp.tmp
echo put BUILD.COM >> ftp.tmp
echo put LAUNCH.COM >> ftp.tmp
echo put REMOTE_DEBUG.COM >> ftp.tmp
echo put SETUP.COM >> ftp.tmp
echo bye >> ftp.tmp

echo Transferring files...
ftp -s:ftp.tmp 1>nul

rem Delete the command script
echo Cleaning up...
del /q ftp.tmp

echo Done!
popd
endlocal
