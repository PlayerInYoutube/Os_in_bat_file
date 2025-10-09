@echo off
cd files
cls
chcp 437 > nul
for %%f in (*) do (
    set "filename=%%~nxf"
        echo %%f
)
set /p modify_file=file name:
type %modify_file%.bat > %modify_file%_modifired.bat
echo %modify_file%.bat modifired!
pause
exit