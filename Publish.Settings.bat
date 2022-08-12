@echo off

rem Additional files to include
set INCLUDE_BRIDGE_FILES=TRUE
rem set INCLUDE_SAMPLE_DATA=TRUE
rem set INCLUDE_C_RUNTIME=TRUE

rem Should the published files be zipped? (requires 7-zip)
set PUBLISH_ZIP=TRUE
rem set TIME_STAMP_ZIP_FILE=TRUE

rem Settings to transfer ZIP file via a COPY command:
set PUBLISH_MODE=COPY
set PUBLISH_DIR=.\docker

rem Settings to transfer ZIP file via FTP (requires WinSCP):
rem set PUBLISH_MODE=FTP
rem set PUBLISH_FTP_SERVER=ftp.somedomain.com
rem set PUBLISH_FTP_USER=user
rem set PUBLISH_FTP_PASSWORD=password
