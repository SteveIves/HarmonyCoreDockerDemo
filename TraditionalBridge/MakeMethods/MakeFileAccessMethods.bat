@echo off
pushd %~dp0
setlocal

rem Configure a Synergy environment
call "%SYNERGYDE64%dbl\dblvars64.bat"

set ROOT=%~dp0
set RPSMFIL=%ROOT%..\..\Repository\rpsmain.ism
set RPSTFIL=%ROOT%..\..\Repository\rpstext.ism
set XFPL_SMCPATH=%ROOT%..\MethodCatalog

rem Generate file access methods for each structure
set STRUCTURES=CUSTOMERS ITEMS ORDERS ORDER_ITEMS VENDORS
set ALIASES=CUSTOMER ITEM ORDER ORDER_ITEM VENDOR
echo Generating source files...
codegen -s %STRUCTURES% -a %ALIASES% -t FileAccessMethods -i . -o %ROOT%..\source\methods -ut XF_INTERFACE=MyApi XF_ELB=EXE:xfplMethods -e -r -lf

rem Delete any existing method catalog XML file to ensure we get a new one
if exist "%XFPL_SMCPATH%\smc.xml" del /q "%XFPL_SMCPATH%\smc.xml"

rem Generate a new method catalog XML file from our method sources
echo Loading method catalog from source files...
dbl2xml %ROOT%..\source\methods\*.dbl -out "%XFPL_SMCPATH%\smc.xml"
if ERRORLEVEL 1 goto parse_fail

rem Load the XML file into the method catalog
echo Exporting method catalog XML file...
dbs DBLDIR:mdu -u "%XFPL_SMCPATH%\smc.xml"
if ERRORLEVEL 1 goto load_fail
echo Method catalog was loaded

rem Unload the method catalog back to an XML file to include repository structures
echo Unloading method catalog...
dbs DBLDIR:mdu -e "%XFPL_SMCPATH%\smc.xml"
if ERRORLEVEL 1 goto load_fail

goto done

:parse_fail
echo ERROR: Failed to extract method catalog data from code
goto done

:load_fail
echo ERROR: Failed to load method catalog
goto done

:unload_fail
echo ERROR: Failed to unload method catalog
goto done

:done
endlocal
popd

pause