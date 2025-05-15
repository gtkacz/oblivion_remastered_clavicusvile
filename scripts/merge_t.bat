@echo off
setlocal EnableDelayedExpansion

rem finds the color image by looking for a file that ends with _color
call :find_color "%~n1"
if !errorlevel!==0 (
	set "color_img=%~1"
) Else (
	call :find_color "%~n2"
	if !errorlevel!==0 (
		set "color_img=%~2"
	) Else (
		echo color image missing!
		goto bad_end
	)
)

rem finds the color image by looking for a file that ends with _alpha
call :find_alpha "%~n1"
if !errorlevel!==0 (
	set "alpha_img=%~1"
) Else (
	call :find_alpha "%~n2"
	if !errorlevel!==0 (
		set "alpha_img=%~2"
	) Else (
		echo alpha image missing!
		goto bad_end
	)
)

@echo on
ffmpeg -hide_banner -v error -i "%color_img%" -i "%alpha_img%" -filter_complex "[1]alphaextract[a];[0][a]alphamerge" "%color_img:~0,-9%combined.png"
@echo off
endlocal
exit /b

:bad_end
endlocal
pause
exit /b

:merge_alpha
echo color: %~1
echo alpha: %~2
echo output %3:
exit /b

:find_color
echo %~1| findstr /rx ".*_color">nul
exit /b %errorlevel%

:find_alpha
echo %~1| findstr /rx ".*_alpha">nul
exit /b %errorlevel%