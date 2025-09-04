<# :# DO NOT REMOVE THIS LINE

:: unlicenserar.cmd
:: Last updated @ v0.12.0.712
:: Copyright (c) 2023, neuralpain
:: Un-license WinRAR

@echo off
mode 78,40
title unlicenserar (v0.13.0.713)

:: PwshBatch.cmd <https://gist.github.com/neuralpain/4ca8a6c9aca4f0a1af2440f474e92d05>
setlocal EnableExtensions DisableDelayedExpansion
set ARGS=%*
if defined ARGS set ARGS=%ARGS:"=\"%
if defined ARGS set ARGS=%ARGS:'=''%

:: cmdUAC.cmd <https://gist.github.com/neuralpain/4bcc08065fe79e4597eb65ed707be90d>
fsutil dirty query %systemdrive% >nul
if %ERRORLEVEL% NEQ 0 (
  cls & echo.
  echo Please grant admin privileges.
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
PowerShell -NoP -C ^"$CMD_NAME='%~n0';Invoke-Expression ('^& {' + (get-content -raw '%~f0') + '} %ARGS%')"
exit /b

# --- PS --- #>

#region Variables
$script_name           = "unlicenserar"
$script_name_uninstall = "un-licenserar"

$rarloc   = ""
$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"
#endregion

#region Switch Configs
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null
$UNINSTALL = $false
#endregion

#region Utility
function Write-Info {
  Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "INFO: $Message" -ForegroundColor DarkCyan
}

function Write-Warn {
  Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "WARN: $Message" -ForegroundColor Yellow
}

function Write-Err {
  Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "ERROR: $Message" -ForegroundColor Red
}

# Format-Text.ps1 <https://gist.github.com/neuralpain/7d0917553a55db4eff482b2eb3fcb9a3>
function Format-Text{
  [CmdletBinding()]param([Parameter(Position=0, Mandatory=$false, HelpMessage="The text to be written", ValueFromPipeline=$true)][String]$Text,[Parameter(Mandatory=$false, HelpMessage="The bit depth of the text to be written")][ValidateSet(8, 24)][Int]$BitDepth,[Parameter(Mandatory=$false, HelpMessage="The foreground color of the text to be written")][ValidateCount(1, 3)][String[]]$Foreground,[Parameter(Mandatory=$false, HelpMessage="The background color of the text to be written")][ValidateCount(1, 3)][String[]]$Background,[Parameter(Mandatory=$false, HelpMessage="The text formatting options to be applied to the text")][String[]]$Formatting);$Esc=[char]27;$Reset="${Esc}[0m"
  switch($BitDepth){8{if($null -eq $Foreground -or $Foreground -lt 0){$Foreground=0}if($null -eq $Background -or $Background -lt 0){$Background=0}if($Foreground -gt 255){$Foreground=255}if($Background -gt 255){$Background=255}$Foreground="${Esc}[38;5;${Foreground}m";$Background="${Esc}[48;5;${Background}m";break}24{foreach($color in $Foreground){;if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_foreground+=";${color}"}foreach($color in $Background){;if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_background+=";${color}"}$Foreground="${Esc}[38;2${_foreground}m";$Background="${Esc}[48;2${_background}m";break;}default{switch($Foreground){'Black'{$Foreground="${Esc}[30m"}'DarkRed'{$Foreground="${Esc}[31m"}'DarkGreen'{$Foreground="${Esc}[32m"}'DarkYellow'{$Foreground="${Esc}[33m"}'DarkBlue'{$Foreground="${Esc}[34m"}'DarkMagenta'{$Foreground="${Esc}[35m"}'DarkCyan'{$Foreground="${Esc}[36m"}'Gray'{$Foreground="${Esc}[37m"}'DarkGray'{$Foreground="${Esc}[90m"}'Red'{$Foreground="${Esc}[91m"}'Green'{$Foreground="${Esc}[92m"}'Yellow'{$Foreground="${Esc}[93m"}'Blue'{$Foreground="${Esc}[94m"}'Magenta'{$Foreground="${Esc}[95m"}'Cyan'{$Foreground="${Esc}[96m"}'White'{$Foreground="${Esc}[97m" }default{$Foreground=""}}switch($Background){'Black'{$Background="${Esc}[40m"}'DarkRed'{$Background="${Esc}[41m"}'DarkGreen'{$Background="${Esc}[42m"}'DarkYellow'{$Background="${Esc}[43m"}'DarkBlue'{$Background="${Esc}[44m"}'DarkMagenta'{$Background="${Esc}[45m"}'DarkCyan'{$Background="${Esc}[46m"}'Gray'{$Background="${Esc}[47m"}'DarkGray'{$Background="${Esc}[100m"}'Red'{Background="${Esc}[101m"}'Green'{$Background="${Esc}[102m"}'Yellow'{$Background="${Esc}[103m"}'Blue'{$Background="${Esc}[104m"}'Magenta'{$Background="${Esc}[105m"}'Cyan'{$Background="${Esc}[106m"}'White'{$Background="${Esc}[107m"}default{$Background=""}}break}}
  if($Formatting.Length -eq 0){$Format=""}else{$i=0;$Format="${Esc}[";foreach($type in $Formatting){switch($type){'Bold'{$Format+="1"}'Dim'{$Format+="2"}'Underline'{$Format+="4"}'Blink'{$Format+="5"}'Reverse'{$Format+="7"}'Hidden'{$Format+="8"}default{$Format+=""}}$i++;if($i -lt ($Formatting.Length)){$Format+=";"}else{$Format+="m";break}}}
  $OutString="${Foreground}${Background}${Format}${Text}${Reset}";Write-Output $OutString;
}

# New-ToastNotification.ps1 <https://gist.github.com/neuralpain/283a2de1e7078c95e0c97a4fb6cc0e08>
function New-Toast {
  [CmdletBinding()] Param([String]$AppId = "oneclickwinrar", [String]$Url, [String]$ToastTitle, [String]$ToastText, [String]$ToastText2, [string]$Attribution, [String]$ActionButtonUrl, [String]$ActionButtonText = "Open documentation", [switch]$KeepAlive, [switch]$LongerDuration)
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText04)
  $RawXml = [xml] $Template.GetXml(); ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) | Out-Null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) | Out-Null; ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "3" }).AppendChild($RawXml.CreateTextNode($ToastText2)) | Out-Null
  $XmlDocument = New-Object Windows.Data.Xml.Dom.XmlDocument; $XmlDocument.LoadXml($RawXml.OuterXml)
  if ($Url) { $XmlDocument.DocumentElement.SetAttribute("activationType", "protocol"); $XmlDocument.DocumentElement.SetAttribute("launch", $Url) }
  if ($Attribution) { $attrElement = $XmlDocument.CreateElement("text"); $attrElement.SetAttribute("placement", "attribution"); $attrElement.InnerText = $Attribution; $bindingElement = $XmlDocument.SelectSingleNode('//toast/visual/binding'); $bindingElement.AppendChild($attrElement) | Out-Null }
  if ($ActionButtonUrl) { $actionsElement = $XmlDocument.CreateElement("actions"); $actionElement = $XmlDocument.CreateElement("action"); $actionElement.SetAttribute("content", $ActionButtonText); $actionElement.SetAttribute("activationType", "protocol"); $actionElement.SetAttribute("arguments", $ActionButtonUrl); $actionsElement.AppendChild($actionElement) | Out-Null; $XmlDocument.DocumentElement.AppendChild($actionsElement) | Out-Null }
  if ($KeepAlive) { $XmlDocument.DocumentElement.SetAttribute("scenario", "incomingCall") } elseif ($LongerDuration) { $XmlDocument.DocumentElement.SetAttribute("duration", "long") }
  $Toast = [Windows.UI.Notifications.ToastNotification]::new($XmlDocument); $Toast.Tag = "PowerShell"; $Toast.Group = "PowerShell"
  if (-not($KeepAlive -or $LongerDuration)) { $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1) }
  $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId); $Notifier.Show($Toast)
}

function Write-Title {
  Write-Host;
  Write-Host "                                ___                __                     "
  Write-Host "                               /\_ \    __        /\ \                    "
  Write-Host "     ___     ___      __    ___\//\ \  /\_\    ___\ \ \/`'\               "
  Write-Host "    / __``\ /`' _ ``\  /`'__``\ /`'___\\ \ \ \/\ \  /`'___\ \ , <         "
  Write-Host "   /\ \L\ \/\ \/\ \/\  __//\ \__/ \_\ \_\ \ \/\ \__/\ \ \\``\             "
  Write-Host "   \ \____/\ \_\ \_\ \____\ \____\/\____\\ \_\ \____\\ \_\ \_\            "
  Write-Host "    \/___/  \/_/\/_/\/____/\/____/\/____/ \/_/\/____/ \/_/\/_/            "
  Write-Host "         __      __              ____    ______  ____                     "
  Write-Host "        /\ \  __/\ \  __        /\  _``\ /\  _  \/\  _``\                 "
  Write-Host "        \ \ \/\ \ \ \/\_\    ___\ \ \L\ \ \ \L\ \ \ \L\ \                 "
  Write-Host "         \ \ \ \ \ \ \/\ \ /`' _ ``\ \ ,  /\ \  __ \ \ ,  /               "
  Write-Host "          \ \ \_/ \_\ \ \ \/\ \/\ \ \ \\ \\ \ \/\ \ \ \\ \                "
  Write-Host "           \ ``\___x___/\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\             "
  Write-Host "            `'\/__//__/  \/_/\/_/\/_/\/_/\/ /\/_/\/_/\/_/\/ /  $(Format-Text "v0.13.0.713" -Foreground Magenta)"
  Write-Host;Write-Host;
}

function Stop-OcwrOperation {
  <#
    .DESCRIPTION
      Termination function with messages and optional script block to run final
      instructions before closing the terminal

    .EXAMPLE
      Stop-OcwrOperation -ExitType [Error|Warning|Complete] -ScriptBlock {...}
  #>
  Param(
    [Parameter(Mandatory=$false)]
    [string]$ExitType,
    [Parameter(Mandatory=$false)]
    [string]$Message
  )

  switch ($ExitType) {
    Terminate { Write-Host "$(if($Message){"$Message`n"})Operation terminated normally." } # i don't know why this is still here but it doesn't affect operation
    Error     { Write-Host "$(if($Message){"ERROR: $Message`n"})Operation terminated with ERROR." -ForegroundColor Red }
    Warning   { Write-Host "$(if($Message){"WARN: $Message`n"})Operation terminated with WARNING." -ForegroundColor Yellow }
    Complete  { Write-Host "$(if($Message){"$Message`n"})Operation completed successfully." -ForegroundColor Green }
    default   { Write-Host "$(if($Message){"$Message`n"})Operation terminated." }
  }

  Pause; exit
}
#endregion

#region Messages
$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"

$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_configuration" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again." 
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$UninstallSuccess = {
  New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."
  Stop-OcwrOperation -ExitType Complete
}

$Error_UninstallerMissing = {
  New-Toast -ToastTitle "WinRAR uninstaller is missing" -ToastText "WinRAR may not be installed correctly." -ToastText2 "Verify installation at $($rarloc)"
  Stop-OcwrOperation -ExitType Error -Message "WinRAR uninstaller is missing"
}

$UnlicenseSuccess = {
  New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
  Stop-OcwrOperation -ExitType Complete
}

$Error_UnlicenseFailed = {
  New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."
  Stop-OcwrOperation -ExitType Error -Message "No license found."
}

$Error_WinrarNotInstalled = {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR is not installed."
}
#endregion

#region Location and Defaults
function Get-InstalledWinrarLocations {
  <#
    .DESCRIPTION
      Confirm the location of any installed versions of WinRAR.
  #>
  if ((Test-Path $winrar64 -PathType Leaf) -and (Test-Path $winrar32 -PathType Leaf)) {
    $script:WINRAR_INSTALLED_LOCATION = $loc96
    $script:WINRAR_IS_INSTALLED = $true
  }
  elseif (Test-Path $winrar64 -PathType Leaf) {
    $script:WINRAR_INSTALLED_LOCATION = $loc64
    $script:WINRAR_IS_INSTALLED = $true
  }
  elseif (Test-Path $winrar32 -PathType Leaf) {
    $script:WINRAR_INSTALLED_LOCATION = $loc32
    $script:WINRAR_IS_INSTALLED = $true
  }
  else {
    $script:WINRAR_INSTALLED_LOCATION = $null
    $script:WINRAR_IS_INSTALLED = $false
  }
}

function Select-WinrarInstallation {
  <#
    .DESCRIPTION
      Find and select which installed architecture of WinRAR to work on.
      Confirm selection if multiple architectures are available.
  #>
  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    Write-Warn "Found 32-bit and 64-bit directories for WinRAR. $(Format-Text "Select one." -Foreground Red)"
    do {
      $query = Read-Host "Enter `"1`" for 32-bit and `"2`" for 64-bit"
      if ($query -eq 1) { $script:WINRAR_INSTALLED_LOCATION = $loc32; break }
      elseif ($query -eq 2) { $script:WINRAR_INSTALLED_LOCATION = $loc64; break }
    } while ($true)
  }
  Write-Info "Selected WinRAR installation: $(Format-Text $($script:WINRAR_INSTALLED_LOCATION) -Foreground White -Formatting Underline)"
}
#endregion

#region Begin Execution
Write-Title

# Verify config, if any
if ($CMD_NAME -ne $script_name) {
  if ($CMD_NAME -eq $script_name_uninstall) {
    $UNINSTALL = $true
  } else { &$Error_UnknownScript }
}

Get-InstalledWinrarLocations
if ($script:WINRAR_IS_INSTALLED) {
  Select-WinrarInstallation
  $rarloc = $script:WINRAR_INSTALLED_LOCATION
} else { &$Error_WinrarNotInstalled }

if ($UNINSTALL) {
  if ($rarloc -eq $loc96) {
    Write-Warn "Both 32-bit and 64-bit versions of WinRAR exist on the system. $(Format-Text "Select one to remove." -Foreground Red -Formatting Underline)"
    do {
      $query = Read-Host "Enter `"1`" for 32-bit and `"2`" for 64-bit"
      if ($query -eq 1) { $rarloc = $loc32; break }
      elseif ($query -eq 2) { $rarloc = $loc32; break }
    } while ($true)
  }
  if (Test-Path "$rarloc\Uninstall.exe" -PathType Leaf) {
    Write-Host "Uninstalling WinRAR ($(if($rarloc -eq $loc64){'x64'}else{'x32'}))... "
    Start-Process "$rarloc\Uninstall.exe" "/s" -Wait
    &$UninstallSuccess
  } else { &$Error_UninstallerMissing }
}

if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
  Write-Host "Un-licensing WinRAR... "
  Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
  &$UnlicenseSuccess
} else { &$Error_UnlicenseFailed }
#endregion
