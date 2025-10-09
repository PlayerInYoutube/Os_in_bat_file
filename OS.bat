@echo off
set "LOCAL_VERSION=1.0"
title os in bat file v%LOCAL_VERSION%
mode con cols=40 lines=9
cls
chcp 65001 > nul
cd /d "%~dp0"

if "%~1"=="check_updates" (
    call :service_check_updates soft
    exit /b
)

:menu
cls
chcp 437 > nul
mode con cols=40 lines=9
cd system
md files
set "menu_choice=null"
echo =========  v%LOCAL_VERSION%  =========
echo 1. files
echo 2. create file
echo 3. delete file
echo 4. create folder
echo 5. modify file
echo 6. check updates
if "%1"=="debug" echo 7. ZAPRET status
echo 0. exit
set /p menu_choice=Enter choice (0-6): 
if "%menu_choice%"=="1" goto explorer
if "%menu_choice%"=="2" goto create_file
if "%menu_choice%"=="3" goto delete_file
if "%menu_choice%"=="4" goto create_folder
if "%menu_choice%"=="5" cd system
if "%menu_choice%"=="5" start modify.bat
if "%menu_choice%"=="6" goto service_check_updates
if "%1"=="debug" if "%menu_choice%"=="6" goto service_status
if "%menu_choice%"=="0" exit /b
goto menu

:create_folder
cls
cd system
cd files
set /p folder_name=folder name:
mkdir %folder_name%
pause
goto menu

:explorer
mode con cols=40 lines=15
cd system
cd files
cls
chcp 437 > nul
for %%f in (*) do (
    set "filename=%%~nxf"
        echo %%f
)
set /p file_name=open file:
start %file_name%
pause
goto menu

:create_file
cls
cd system
cd files
set /p NAME=File name:
set /p NAMEE=text in file:
echo %NAMEE% > %NAME%.txt
echo file %NAME%.txt created!
pause
goto menu

:delete_file
cls
cd system
cd files
set /p NAMEEE=File name:
DEL %NAMEEE%
pause
goto menu

:service_status
cls
chcp 437 > nul

sc query "zapret" >nul 2>&1
if !errorlevel!==0 (
    for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube 2^>nul') do echo Service strategy installed from "%%B"
)

call :test_service zapret
echo:

tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel!==0 (
    call :PrintGreen "Bypass (winws.exe) is ACTIVE"
) else (
    call :PrintRed "Bypass (winws.exe) NOT FOUND"
)

pause
goto menu

:test_service
set "ServiceName=%~1"
set "ServiceStatus="

for /f "tokens=3 delims=: " %%A in ('sc query "%ServiceName%" ^| findstr /i "STATE"') do set "ServiceStatus=%%A"
set "ServiceStatus=%ServiceStatus: =%"

if "%ServiceStatus%"=="RUNNING" (
    if "%~2"=="soft" (
        echo "%ServiceName%" is ALREADY RUNNING as service, use "service.bat" and choose "Remove Services" first if you want to run standalone bat.
        pause
        exit /b
    ) else (
        echo "%ServiceName%" service is RUNNING.
    )
) else if "%ServiceStatus%"=="STOP_PENDING" (
    call :PrintYellow "!ServiceName! is STOP_PENDING, that may be caused by a conflict with another bypass. Run Diagnostics to try to fix conflicts"
) else if not "%~2"=="soft" (
    echo "%ServiceName%" service is NOT running.
)
pause
goto menu

:service_check_updates
chcp 437 > nul

:: Set current version and URLs
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/main/.service/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/Flowseal/zapret-discord-youtube/releases/tag/"
set "GITHUB_DOWNLOAD_URL=https://github.com/Flowseal/zapret-discord-youtube/releases/latest/download/zapret-discord-youtube-"

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

:: Error handling
if not defined GITHUB_VERSION (
    echo Warning: failed to fetch the latest version. Check your internet connection. This warning does not affect the operation of zapret
    pause
    if "%1"=="soft" exit /b 
    goto menu
)

:: Version comparison
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
    echo Latest version installed: %LOCAL_VERSION%
) else (
    echo New version available: %GITHUB_VERSION%
    echo Release page: %GITHUB_RELEASE_URL%%GITHUB_VERSION%
    
    set "CHOICE="
    set /p "CHOICE=Do you want to automatically download the new version? (Y/N) (default: Y) "
    if "!CHOICE!"=="" set "CHOICE=Y"
    if "!CHOICE!"=="y" set "CHOICE=Y"

    if /i "!CHOICE!"=="Y" (
        echo Opening the download page...
        start "" "%GITHUB_DOWNLOAD_URL%%GITHUB_VERSION%.rar"
    )
)

if "%1"=="soft" exit /b 
pause
goto menu