@echo off
rem This batch file publishes your Harmony Core service for deployment to a
rem hosting system, for example to an IIS server. The script does the
rem following:
rem 
rem  1. Publishes the application to a temporary folder called PUBLISH
rem
rem  2. Copies in the Traditional Bridge host program and launch script
rem
rem  3. Replaces the web.config created by the publish operation with
rem     one that sets the ASPNETCORE_ENVIRONMENT to Production
rem
rem  4. Optionally includes the content of the SampleData folder
rem     (Only if environment variuable INCLUDE_SAMPLE_DATA=TRUE)
rem
rem  5. Optionally includes VC++ runtime files
rem     (Only if environment variable INCLUDE_C_RUNTIME=TRUE)
rem
rem  6. Optionally zips the PUBLISH folder to a date and time stamped zip file
rem     HarmonyCoreService-platform-yyyymmdd-hhmm.zip
rem     (Only if 7-zip is installed and environment variable PUBLISH_ZIP=TRUE)
rem
rem  7. Deletes the temporary PUBLISH folder
rem     (Only if the a zip file was created)
rem
rem  8. Transfers the ZIP file to a specified location via COPY or FTP.
rem     (Only if a zip file was created, and the PUBLISH_MODE=COPY
rem     and PUBLISH_DIR is set to a valid directory path, or WinSCP is
rem     installed, PUBLISH_MODE=FTP and the environment variables
rem     PUBLISH_FTP_SERVER PUBLISH_FTP_USER and PUBLISH_FTP_PASSWORD
rem     are set)
rem 
rem A good way to set these environment variables is to create a batch
rem file named Publish.Settings.bat in the main solution folder. If
rem the file is present it will be executed when this script runs.

setlocal EnableDelayedExpansion

set SolutionDir=%~dp0
set SYNCPMOPT=-wd=316

pushd "%SolutionDir%"

rem If we have a settings file, execute it
if exist Publish.Settings.bat call Publish.Settings.bat

set RPSMFIL=%SolutionDir%Repository\rpsmain.ism
set RPSTFIL=%SolutionDir%Repository\rpstext.ism

set DeployDir=%SolutionDir%PUBLISH

rem Select the platform we are publishing for
if /i "%1" == "WINDOWS" goto publish_windows
if /i "%1" == "LINUX" goto publish_linux

:ask_platform
  set /p answer=Publish for (W)indows or (L)inux ? 
  if /i "%answer:~,1%" EQU "W" goto publish_windows
  if /i "%answer:~,1%" EQU "L" goto publish_linux
  goto ask_platform

:publish_windows
set PLATFORM=windows
set RUNTIME=win7-x64
goto do_publish

:publish_linux
set PLATFORM=linux
set RUNTIME=linux-x64

:do_publish

rem If there is an old PUBLISH folder, delete it
if exist "%DeployDir%\." (
  echo Deleting previous deployment folder
  rmdir /S /Q "%DeployDir%" > nul 2>&1
)

rem The dotnet publish command will not build the TraditionalBridge project
rem so first we'll build the solution to make sure its output is up to date.

echo Building solution
msbuild -nologo -p:platform="Any CPU" -p:configuration=Debug -verbosity:quiet

if ERRORLEVEL 1 (
  echo ERROR: Build failed!
  goto done
)

rem Publish the application
echo Publishing for %PLATFORM% to %DeployDir%

pushd Services.Host

dotnet publish -nologo -p:platform=AnyCPU --configuration Debug --runtime %RUNTIME% --self-contained --output "%DeployDir%" --verbosity quiet

if ERRORLEVEL 1 (
  echo ERROR: Publish failed!
  popd
  goto done
)

echo Publish complete

popd

rem Include the Traditional Bridge host program and startup script
echo Copying traditional bridge files
copy /y TraditionalBridge\EXE\host.dbr "%DeployDir%" > nul 2>&1
copy /y TraditionalBridge\EXE\host.dbp "%DeployDir%" > nul 2>&1
if /i "%PLATFORM%" == "windows" (
  copy /y TraditionalBridge\launch.bat "%DeployDir%" > nul 2>&1
)
if /i "%PLATFORM%" == "linux" (
  copy /y TraditionalBridge\launch "%DeployDir%" > nul 2>&1
  copy /y TraditionalBridge\startService "%DeployDir%" > nul 2>&1
)

if /i "%PLATFORM%" == "windows" (
  rem Replace the web.config file with our own version that sets the
  rem ASPNETCORE_ENVIRONMENT to Production
  if exist "%DeployDir%\web.config" (
    echo Copying web.config
    del  /Q "%DeployDir%\web.config"
    copy /Y "%SolutionDir%\web.config" "%DeployDir%\web.config" > nul 2>&1
  )
)

if /i "%INCLUDE_SAMPLE_DATA%" == "TRUE" (
  echo Copying sample data
  if not exist "%DeployDir%\SampleData\." mkdir "%DeployDir%\SampleData"
  copy /y SampleData\*.* "%DeployDir%\SampleData" > nul 2>&1
)

if /i "%PLATFORM%" == "windows" (
  rem At the time of writing, Azure AppService does not provide the VS2019 C++
  rem runtime so if we are publishing for AppService we need to include it
  if /i "%INCLUDE_C_RUNTIME%" == "TRUE" (
    echo Copying C++ runtime
    copy /y vcredistFiles\*.* "%DeployDir%" > nul 2>&1
  )
)

if /i "%PLATFORM%" == "linux" (
  echo Applying Linux line endings
  tools\dos2unix "%DeployDir%\launch" > nul 2>&1
  tools\dos2unix "%DeployDir%\startService" > nul 2>&1
  tools\dos2unix "%DeployDir%\SampleData\*.*" > nul 2>&1
)

if /i not "%PUBLISH_ZIP%" == "TRUE" (
  goto done
)

if /i "%TIME_STAMP_ZIP_FILE%" == "TRUE" (
  rem Pick a zip file name
  set yyyymmdd=%date:~-4%%date:~4,2%%date:~7,2%
  set hh=%TIME:~0,2%
  set mm=%TIME:~3,2%
  set zipFile=%SolutionDir%HarmonyCoreService-%PLATFORM%-%yyyymmdd%-%hh%%mm%.zip
) else (
  set zipFile=%SolutionDir%HarmonyCoreService-%PLATFORM%.zip
)

if exist "%DeployDir%\." (
  if exist "%ProgramW6432%\7-Zip\7z.exe" (
    echo Zipping to %zipFile%
    pushd "%DeployDir%"
    "%ProgramW6432%\7-Zip\7z.exe" a -r -bso0 -bsp0 "%zipFile%" *

    if ERRORLEVEL 0 (
      echo Zip file created
    ) else (
      echo ERROR: Failed to create zip file!
      popd
      goto done
    )
    popd
  ) else (
    echo WARNING: Unable to zip the deployment directory because 7-zip is not installed!
    echo The published application is in %DeployDir%
  )
)

rem If the zip file exists, delete the publish folder
if exist "%zipFile%" (
  echo Deleting deployment folder %DeployDir%
  rmdir /S /Q "%DeployDir%" > nul 2>&1
) else (
    goto done
)

rem Do we have PUBLISH_MODE set?
if not defined PUBLISH_MODE (
  echo Zip file distribution has not been configured
  goto done
)

rem Distribution via COPY?
if /i "%PUBLISH_MODE%" == "COPY" (
  rem Do we have a direrctory to copy to?
  if not defined PUBLISH_DIR (
    echo ERROR: Unable to copy zip file to staging server because PUBLISH_DIR is not set!
    goto done
  )

  rem Does the direrctory exist?
  rem if not exist "%PUBLISH_DIR%\." (
  rem   echo ERROR: Unable to copy zip file to staging server because directory %PUBLISH_DIR% does not exist!
  rem   goto done
  rem )

  rem Copy the file
  copy /y "%zipFile%" "%PUBLISH_DIR%" > nul 2>&1

  rem Did it work?
  if ERRORLEVEL 0 (
    echo The zip file was successfully copied to "%PUBLISH_DIR%"
  ) else (
    echo ERROR: Failed to copy zip file to "%PUBLISH_DIR%"
  )

  goto done
)

rem Distribution via FTP?
if /i "%PUBLISH_MODE%" == "FTP" (

  rem Do we have an FTP username?
  if not defined PUBLISH_FTP_SERVER (
    echo WARNING: Unable to FTP the zip file to staging server because PUBLISH_FTP_SERVER is not set!
    goto done
  )

  rem Do we have an FTP username?
  if not defined PUBLISH_FTP_USER (
    echo WARNING: Unable to FTP the zip file to staging server because PUBLISH_FTP_USER is not set!
    goto done
  )

  rem Do we have an FTP password?
  if not defined PUBLISH_FTP_PASSWORD (
    echo WARNING: Unable to FTP the zip file to staging server because PUBLISH_FTP_USER is not set!
    goto done
  )

  rem Is WinSCP installed?
  if exist "%ProgramFiles(x86)%\WinSCP\WinSCP.com" (
    echo Uploading zip file to staging server
    rem Yes, upload the ZIP file to the staging server
    "%ProgramFiles(x86)%\WinSCP\WinSCP.com" /command "open ftp://%PUBLISH_FTP_USER%:%PUBLISH_FTP_PASSWORD%@%PUBLISH_FTP_SERVER%/" "put %zipFile% /" "exit"
     if ERRORLEVEL 0 (
       echo SUCCESS: The zip file was successfully uploaded to the staging server.
     ) else (
       echo ERROR: Failed to upload the zip file to the staging server!
     )
  ) else (
      echo WARNING: Unable to upload the zip file to staging server because WinSCP is not installed!
  )
  goto done
)

echo PUBLISH_MODE is set to an unsupported value %PUBLISH_MODE%. Use COPY or FTP.

:done
popd
endlocal
