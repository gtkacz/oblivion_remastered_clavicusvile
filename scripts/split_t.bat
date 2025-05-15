@echo off
if [%1]==[] (
	echo no input provided!
	pause
	exit /b
)
@echo on
ffmpeg -hide_banner -v error -i "%1" -filter_complex "[0]geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255'" "%~n1_color.png"
ffmpeg -hide_banner -v error -i "%1" -filter_complex "[0]geq=r='255':g='255':b='255':a='p(X,Y)'" "%~n1_alpha.png"
@echo off
if not %errorlevel%==0 pause
