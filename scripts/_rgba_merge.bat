@echo off
setlocal EnableDelayedExpansion

where ffmpeg>nul
if not !errorlevel!==0 (
	echo ffmpeg not found, you should put the executable in this directory or add it to your path!
	goto bad_end
)

for %%x in (%*) do (
   echo %%~nx| findstr /rx ".*_r">nul && set "img_r=%%~x"
   echo %%~nx| findstr /rx ".*_g">nul && set "img_g=%%~x"
   echo %%~nx| findstr /rx ".*_b">nul && set "img_b=%%~x"
   echo %%~nx| findstr /rx ".*_a">nul && set "img_a=%%~x"
)

if [%img_r%]==[] echo red channel not found! Ensure you are passing a file that ends with _r!
if [%img_g%]==[] echo green channel not found! Ensure you are passing a file that ends with _g!
if [%img_b%]==[] echo blue channel not found! Ensure you are passing a file that ends with _b!
if [%img_a%]==[] echo alpha channel not found! Ensure you are passing a file that ends with _a!

if [%img_r%]==[] goto bad_end
if [%img_g%]==[] goto bad_end
if [%img_b%]==[] goto bad_end
if [%img_a%]==[] goto bad_end

rem multi command equivalent so that I don't loose my mind the next time around
@echo on
ffmpeg -y -i "%img_r%" -filter_complex "[0]format=rgba,geq=r='r(X,Y)':g='0':b='0':a='0'" -c png -f rawvideo - ^
 | ffmpeg -y -i - -i "%img_g%" -filter_complex "[1]format=rgba,geq=r='0':g='r(X,Y)':b='0':a='0'[g];[0][g]blend=all_mode=addition" -c png -f rawvideo - ^
 | ffmpeg -y -i - -i "%img_b%" -filter_complex "[1]format=rgba,geq=r='0':g='0':b='r(X,Y)':a='0'[b];[0][b]blend=all_mode=addition" -c png -f rawvideo - ^
 | ffmpeg -y -i - -i "%img_a%" -filter_complex "[1]format=rgba,geq=r='0':g='0':b='0':a='r(X,Y)'[a];[0][a]blend=all_mode=addition" "%img_a:~0,-5%combined.png"
if not !errorlevel!==0 pause
endlocal
exit /b

:bad_end
endlocal
pause
exit /b