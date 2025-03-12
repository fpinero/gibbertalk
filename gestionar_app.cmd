@echo off
setlocal enabledelayedexpansion

title Python Application Manager

:menu
cls
echo === PYTHON APPLICATION MANAGER ===
echo 1. Check application status
echo 2. Stop application
echo 3. Start application
echo 4. Check API health
echo 5. View application logs
echo 6. Exit

set /p option=Select an option: 

if "%option%"=="1" goto check
if "%option%"=="2" goto stop
if "%option%"=="3" goto start
if "%option%"=="4" goto health
if "%option%"=="5" goto logs
if "%option%"=="6" goto exit
echo Invalid option
pause
goto menu

:check
echo Checking if Python application is running...
netstat -ano | findstr :5001 | findstr LISTENING
if %ERRORLEVEL% EQU 0 (
    echo Port 5001 is in use.
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5001 ^| findstr LISTENING') do (
        echo PID: %%a
        tasklist /fi "PID eq %%a"
    )
) else (
    echo Port 5001 is free. The application is not running.
)
pause
goto menu

:stop
echo Stopping the application...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5001 ^| findstr LISTENING') do (
    echo Process found with PID: %%a
    set /p confirm=Are you sure you want to stop this process? (y/n): 
    if /i "!confirm!"=="y" (
        taskkill /PID %%a /F
        echo Process stopped.
    ) else (
        echo Operation cancelled.
    )
)
pause
goto menu

:start
echo Starting the application...
start /B python app.py > app.log 2>&1
echo Application started. Logs are being saved to app.log
pause
goto menu

:health
echo Checking API health status...
curl -s http://localhost:5001/api/health
echo.
pause
goto menu

:logs
echo Application logs:
if exist app.log (
    type app.log
    echo.
    echo NOTE: To view the complete file, use: notepad app.log
) else (
    echo Log file not found (app.log).
)
pause
goto menu

:exit
echo Goodbye!
exit /b