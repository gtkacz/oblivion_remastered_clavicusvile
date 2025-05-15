@echo off
REM ---------------------------------------------------
REM merge.bat
REM Usage: merge.bat *normal.png *roughness.png *metallic.png
REM Output: <base>_merged.png
REM ---------------------------------------------------

REM -- Reset variables
set "NORMAL="
set "ROUGHNESS="
set "METALLIC="
set "BASE="

REM -- Loop over all args and detect by suffix
for %%F in (%*) do (
    set "FNAME=%%~nF"
    setlocal enabledelayedexpansion
    if /i "!FNAME:~-7!"=="_normal"    set "NORMAL=%%~fF" & set "THISBASE=!FNAME:~0,-7!"
    if /i "!FNAME:~-10!"=="_roughness" set "ROUGHNESS=%%~fF" & set "THISBASE=!FNAME:~0,-10!"
    if /i "!FNAME:~-9!"=="_metallic"  set "METALLIC=%%~fF" & set "THISBASE=!FNAME:~0,-9!"
    endlocal & if defined THISBASE if not defined BASE set "BASE=!THISBASE!"
)

REM -- Validate we found all three inputs
if not defined NORMAL (
    echo ERROR: Could not find a *_normal.png argument.
    pause
    exit /b 1
)
if not defined ROUGHNESS (
    echo ERROR: Could not find a *_roughness.png argument.
    pause
    exit /b 1
)
if not defined METALLIC (
    echo ERROR: Could not find a *_metallic.png argument.
    pause
    exit /b 1
)

REM -- Build output name
set "OUT=%BASE%_merged.png"

@echo on
ffmpeg -hide_banner -v error ^
  -i "%NORMAL%"    ^ REM R & G from normal ^
  -i "%ROUGHNESS%" ^ REM B from roughness ^
  -i "%METALLIC%"  ^ REM A from metallic ^
  -filter_complex ^
    "[0][1][2]geq=^
       r='r(0,X,Y)':^
       g='g(0,X,Y)':^
       b='b(1,X,Y)':^
       a='a(2,X,Y)'" ^
  "%OUT%"

@echo off
if not %errorlevel%==0 pause
