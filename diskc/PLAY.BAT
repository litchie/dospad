@echo off
goto menu
:menu
cls
echo.
echo Enter a choice with keyboard:
echo.
echo 1 ---- Duke
echo 2 ---- Haunted
echo 3 ---- Duke2
echo 4 ---- Edit
echo.
:choice
choice /c:1234
if ERRORLEVEL 4 goto edit
if ERRORLEVEL 3 goto duke2
if ERRORLEVEL 2 goto haunted
if ERRORLEVEL 1 goto duke
goto choice

REM ----------------------------------------
:haunted
cd apps\haunted
haunted
cd ..\..
goto menu

REM ----------------------------------------
:duke
cd apps\duke
cycles 1500
dn1
cd ..\..
goto menu

REM ----------------------------------------
:duke2
cd apps\duke2
nukem2
cd ..\..
goto menu

REM ----------------------------------------

:edit
cd apps\edit\bin
edit
cd ..\..
goto menu

REM ----------------------------------------
:quit
exit
:end


