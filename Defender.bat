@echo off
setlocal

REM This script trys to eliminate the problem with false positives when using Windows Defender with hMailServer
REM It mitigates the misindentification by checking twice.
REM It also creates a LOG, so you can see how many times it fails and the progress of the mitigation

REM Set the date format for the log file name (Brazilian convention: dd-mm-yyyy)
set "dateformat=dd-mm-yyyy"

REM Get the current date in the specified format
for /F "tokens=1-3 delims=/-" %%a in ("%date%") do (
  set "day=%%a"
  set "month=%%b"
  set "year=%%c"
)

REM Set the log file path. Change to fit your needs
set "logfolder=C:\Learn\Log"
set "logfile=%logfolder%\DefenderLog_%year%-%month%-%day%.log"
set "filettoverify=%~1%"

rem Generate a unique temporary log file name, used to save the output of Windows Defender
set "templogfile=%logfolder%\log_%RANDOM%.txt"

REM Check if a file parameter is passed
if "%~1"=="" (
  echo No file specified.
  echo Usage: %~nx0 "path_to_file"
  exit /b
)

REM Run Windows Defender for the first time
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File "%~1" -DisableRemediation > "%templogfile%"
REM Check if the file is good to go
if %errorlevel% equ 0 (
    Rem File is clean
    del "%templogfile%"
    exit /b 0
) 

REM Windows Defender ended with an errorlevel different from zero
REM Check if a virus was found or an error occur. 
REM In case of virus, this string will be found on the temporary log
findstr /C:"LIST OF DETECTED THREATS" "%templogfile%" > nul
if %errorlevel% equ 0 (
    REM It is a virus
    echo Virus detected on file: "%filettoverify%" >> "%logfile%"
    REM Save the temporary log on the permanent log
    type "%templogfile%" >> "%logfile%"
    REM Deletes the temporary log and ends with errorlevel 2
    del "%templogfile%"
    exit /b 2
) 
REM It was some error. Try again
echo "Fail on the first verification. Trying again." >> "%logfile%"
REM Wait a bit in order to make file system to settle
REM Most times the error on the first run is a failure on reading the file
REM Waiting a bit solves this issue. 
timeout /T 3
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File "%~1" -DisableRemediation > "%templogfile%"
if %errorlevel% equ 0 (
    REM Second rum was fine. There was no viruses
    echo File was clean on the second verification: "%filettoverify%" >> "%logfile%"
    del "%templogfile%"
    exit /b 0
)

REM Lets save the second temporary log for debuging or virus reporting
type "%templogfile%" >> "%logfile%"
REM verify the temporary log to see if a virus was found or some other error occur again
findstr /C:"LIST OF DETECTED THREATS" "%templogfile%" > nul
if %errorlevel% equ 0 (
    REM It is a virus
    echo **Virus found on the second verification: "%filettoverify%" >> "%logfile%"
    REM Delete the temporary log and ends with error level 2
    del "%templogfile%"
    exit /b 2
) 
REM it is some error again. Give up
echo "The scan faild for the second time " "%filettoverify%"  >> "%logfile%"

del "%templogfile%"
exit /b 0





endlocal