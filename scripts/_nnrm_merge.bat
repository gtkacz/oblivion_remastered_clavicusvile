@echo off
setlocal EnableDelayedExpansion

where ffmpeg>nul
if not !errorlevel!==0 (
	echo ffmpeg not found, you should put the executable in this directory or add it to your path!
	goto bad_end
)

for %%x in (%*) do (
   echo %%~nx| findstr /rx ".*_n">nul && set "img_n=%%~x"
   echo %%~nx| findstr /rx ".*_r">nul && set "img_r=%%~x"
   echo %%~nx| findstr /rx ".*_m">nul && set "img_m=%%~x"
)

if [%img_n%]==[] echo normal map not found! Ensure you are passing a file that ends with _n!
if [%img_r%]==[] echo roughness map not found! Ensure you are passing a file that ends with _r!
if [%img_m%]==[] echo metalicity map not found! Ensure you are passing a file that ends with _m!

if [%img_n%]==[] goto bad_end
if [%img_r%]==[] goto bad_end
if [%img_m%]==[] goto bad_end

rem multi command equivalent so that I don't loose my mind the next time around
rem ffmpeg -y -i "%img_n%" -filter_complex "[0]format=rgba,geq=r='p(X,Y)':g='p(X,Y)':b='0':a='0'" -c png -f rawvideo - ^
rem  | ffmpeg -y -i - -i "%img_r%" -filter_complex "[1]format=rgba,geq=r='0':g='0':b='r(X,Y)':a='0'[a];[0][a]blend=all_mode=addition" -c png -f rawvideo - ^
rem  | ffmpeg -y -i - -i "%img_m%" -filter_complex "[1]format=rgba,geq=r='0':g='0':b='0':a='r(X,Y)'[a];[0][a]blend=all_mode=addition" "%img_n:~0,-5%combined.png"
@echo on
ffmpeg -y -i "%img_n%" -i "%img_r%" -i "%img_m%" -filter_complex "[0]format=rgba,geq=r='p(X,Y)':g='p(X,Y)':b='0':a='0'[rg];[1]format=rgba,geq=r='0':g='0':b='r(X,Y)':a='0'[b];[2]format=rgba,geq=r='0':g='0':b='0':a='r(X,Y)'[a];[rg][b]blend=all_mode=addition[rgb];[rgb][a]blend=all_mode=addition" "%img_n:~0,-5%combined.png"
@echo off
endlocal
exit /b

:bad_end
endlocal
pause
exit /b