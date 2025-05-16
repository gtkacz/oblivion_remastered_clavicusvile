@echo off
setlocal EnableDelayedExpansion

where ffmpeg>nul
if not !errorlevel!==0 (
	echo ffmpeg not found, you should put the executable in this directory or add it to your path!
	goto bad_end
)

if [%1]==[] (
	echo no input provided!
	pause
	exit /b
)

ffmpeg -i "%1" -filter_complex "[0]geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255'" -pix_fmt rgb24 "%~n1_color.png"
if not !errorlevel!==0 goto bad_end
ffmpeg -i "%1" -filter_complex "[0]geq=r='alpha(X,Y)':g='alpha(X,Y)':b='alpha(X,Y)':a='255'" -pix_fmt gray "%~n1_alpha.png"
if not !errorlevel!==0 goto bad_end

endlocal
exit /b

:bad_end
endlocal
pause
exit /b