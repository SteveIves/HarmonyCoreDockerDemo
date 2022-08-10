@echo off
pushd %~dp0
setlocal EnableDelayedExpansion

rem Configure a Synergy environment
rem call "%SYNERGYDE32%dbl\dblvars32.bat"
call "%SYNERGYDE64%dbl\dblvars64.bat"

rem Set any environment required by the underlying code




rem If we have a log level, use it, else default to 2
if "%~1"=="" (
  set HARMONY_LOG_LEVEL=2
) else (
  set HARMONY_LOG_LEVEL=%1
)

rem Launch the host program
dbs host.dbr

rem Launch the host program for remote debugging
rem dbr -dv -rd 4444:60 host.dbr

endlocal
popd