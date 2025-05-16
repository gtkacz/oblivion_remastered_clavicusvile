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

ffmpeg -i "%1" -filter_complex "[0]geq=r='r(X,Y)':g='r(X,Y)':b='r(X,Y)':a='255'" -pix_fmt gray "%~n1_r.png"
if not !errorlevel!==0 goto bad_end
ffmpeg -i "%1" -filter_complex "[0]geq=r='g(X,Y)':g='g(X,Y)':b='g(X,Y)':a='255'" -pix_fmt gray "%~n1_g.png"
if not !errorlevel!==0 goto bad_end
ffmpeg -i "%1" -filter_complex "[0]geq=r='b(X,Y)':g='b(X,Y)':b='b(X,Y)':a='255'" -pix_fmt gray "%~n1_b.png"
if not !errorlevel!==0 goto bad_end
ffmpeg -i "%1" -filter_complex "[0]geq=r='alpha(X,Y)':g='alpha(X,Y)':b='alpha(X,Y)':a='255'" -pix_fmt gray "%~n1_a.png"
if not !errorlevel!==0 goto bad_end

endlocal
exit /b

:bad_end
endlocal
pause
exit /b