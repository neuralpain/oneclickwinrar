<# :# ###

:: licenserar.cmd, version 0.1
:: License WinRAR

@echo off
title licenserar.cmd, v0.1
:: uses PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%

:: uses cmdUAC.cmd <https://gist.github.com/neuralpain/4bcc08065fe79e4597eb65ed707be90d>
fsutil dirty query %systemdrive% >nul
if %ERRORLEVEL% NEQ 0 (
  cls & echo.
  echo This script requires administrative priviledges.
  echo Attempting to elevate...
  goto UAC_Prompt
) else ( goto :begin_script )

:UAC_Prompt
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
echo Set objShell = CreateObject("Shell.Application")>"%tmp%\cmdUAC.vbs"
echo objShell.ShellExecute "cmd.exe", "/c start " ^& Chr(34) ^& "." ^& Chr(34) ^& " /d " ^& Chr(34) ^& "%CD%" ^& Chr(34) ^& " cmd /c %n%", "", "runas", ^1>>"%tmp%\cmdUAC.vbs"
cscript "%tmp%\cmdUAC.vbs" //Nologo
del "%tmp%\cmdUAC.vbs"
goto :eof

:begin_script
PowerShell -NoP -C ^"Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
exit /b

# --- PS --- #>

$rarkey = "RAR registration data`r`nTechTools.net`r`nUnlimited Company License`r`nUID=be495af2e04c51526b85`r`n64122122506b85be56d054210a35c74d3d4b85c98b58c1c03635b4`r`n931f702fd05f10d8593c60fce6cb5ffde62890079861be57638717`r`n7131ced835ed65cc743d9777f2ea71a8e32c7e593cf66794343565`r`nb41bcf56929486b8bcdac33d50ecf77399607b61cbd4c7c227f192`r`n2b3291c3cf4822a590ea57181b47bfe6cf92ddc40a7de2d2796819`r`n1781857ba6b1b67a2b15bc5f9dfb682cca338eaa5c606da560397f`r`n6c6efc340004788adcfe55aa8c331391a95957b7e7401955721377"
$rarreg = "$env:ProgramFiles\WinRAR\rarreg.key"

if (-not(Test-Path $rarreg -PathType Leaf)) { 
  [IO.File]::WriteAllLines($rarreg, $rarkey)
}
