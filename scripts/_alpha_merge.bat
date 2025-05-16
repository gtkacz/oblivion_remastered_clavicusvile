@echo off
setlocal EnableDelayedExpansion

where ffmpeg>nul
if not !errorlevel!==0 (
	echo ffmpeg not found, you should put the executable in this directory or add it to your path!
	goto bad_end
)

for %%x in (%*) do (
   echo %%~nx| findstr /rx ".*_color">nul && set "img_c=%%~x"
   echo %%~nx| findstr /rx ".*_alpha">nul && set "img_a=%%~x"
)

if [%img_c%]==[] echo color map not found! Ensure you are passing a file that ends with _color!
if [%img_a%]==[] echo alpha map not found! Ensure you are passing a file that ends with _alpha!

if [%img_c%]==[] goto bad_end
if [%img_a%]==[] goto bad_end

rem multi command equivalent so that I don't loose my mind the next time around
rem ffmpeg -y -i "%img_c%" -filter_complex "[0]format=rgba,geq=r='p(X,Y)':g='p(X,Y)':b='p(X,Y)':a='0'" -c png -f rawvideo - ^
rem | ffmpeg -y -i - -i "%img_a%" -filter_complex "[1]format=rgba,geq=r='0':g='0':b='0':a='r(X,Y)'[a];[0][a]blend=all_mode=addition" "%img_c:~0,-9%combined.png"
@echo on
ffmpeg -y -i "%img_c%" -i "%img_a%" -filter_complex "[0]format=rgba,geq=r='p(X,Y)':g='p(X,Y)':b='p(X,Y)':a='0'[rgb];[1]format=rgba,geq=r='0':g='0':b='0':a='r(X,Y)'[a];[rgb][a]blend=all_mode=addition" "%img_c:~0,-9%combined.png"
@echo off
if not !errorlevel!==0 pause
endlocal
exit /b

:bad_end
endlocal
pause
exit /b