<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: Last updated @ v0.12.2.713
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
mode 78,40
title oneclickrar (v0.12.2.713)

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

<#
  .SYNOPSIS
    Install and license WinRAR Archiver.

  .DESCRIPTION
    oneclickrar.cmd is a combination of installrar.cmd and licenserar.cmd with
    modifications and added functionality.

  .NOTES
    Complete naming pattern:

    <licensee>_<license-type>_<script-name>_<architecture>_<version>_<tags>.cmd

  .EXAMPLE
    oneclickrar.cmd             --- Install latest English 64-bit version with
                                    default license information
    oneclickrar_x32.cmd         --- Install latest English 32-bit version with
                                    default license information
    oneclickrar_700.cmd         --- Install English 64-bit version 7.00
                                    with default license information
    one-clickrar_624.cmd        --- Download English 64-bit version 6.24
    oneclickrar_x32_701_fr.cmd  --- Install French 32-bit version 7.01
    one-click-rar_x64_700.cmd   --- Install English 64-bit version 7.00 and keep
                                    the downloaded installer
    My Name_My License Type_oneclickrar.cmd
                                --- Custom license with default installation
    My Name_oneclick-rar.cmd    --- Overwrite current license with "My Name" as
                                    the licensee and use default license type
    My Name_My License Type_oneclick-rar_x64_700_ru.cmd
                                --- Full configuration to install Russian 64-bit
                                    version 7.00 and overwrite any existing
                                    license with the custom license information
#>

# ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -contains "S-1-5-32-544"
# ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

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

#region Utility
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
  #TODO - Allow action button to execute script commands
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
  Write-Host "            `'\/__//__/  \/_/\/_/\/_/\/_/\/ /\/_/\/_/\/_/\/ /  $(Format-Text "v0.12.2.713" -Foreground Magenta)"
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

function Confirm-QueryResult {
  <#
    .DESCRIPTION
      A function for structuring queries better within the code.
      The code does not have to be altered much to change the way the response
      is received; thereby enhancing readability and efficiency.

    .EXAMPLE
      Confirm-QueryResult -Expect[Positive|Negative] `
        -Query "...?" `
        -ResultPositive { ... } `
        -ResultNegative { ... }
  #>
  [CmdletBinding()]
  param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Query,
    [switch]$ExpectPositive,
    [switch]$ExpectNegative,
    [Parameter(Mandatory=$true)]
    [scriptblock]$ResultPositive,
    [Parameter(Mandatory=$true)]
    [scriptblock]$ResultNegative
  )

  $q = Read-Host "$Query $(if($ExpectPositive){"(Y/n)"}elseif($ExpectNegative){"(y/N)"})"

  if($ExpectPositive){
    if (-not([string]::IsNullOrEmpty($q)) -and ($q.Length -eq 1 -and $q -match '(N|n)')) {
      if ($ResultNegative) { & $ResultNegative }
    } else {
      if ($ResultPositive) { & $ResultPositive } # Default is positive
    }
  }
  elseif($ExpectNegative){
    if (-not([string]::IsNullOrEmpty($q)) -and ($q.Length -eq 1 -and $q -match '(Y|y)')) {
      if ($ResultPositive) { & $ResultPositive }
    } else {
      if ($ResultNegative) { & $ResultNegative } # Default is negative
    }
  }
  else {
    Write-Err "Nothing to expect."
    Stop-OcwrOperation -ExitType Error
  }
}
#endregion

#region Variables
$script_name                         = "oneclickrar"
$script_name_overwrite               = "oneclick-rar"
$script_name_download_only           = "one-clickrar"
$script_name_download_only_overwrite = "one-click-rar"

$winrar_name         = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# old WinRAR name pattern
$wrar_name           = "wrar"
$wrar_name_pattern   = "^wrar"
$wrar_file_pattern   = "wrar\d{3}\w*\.exe"

$rarloc   = $null
$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$loc96    = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$rarreg = $null
$rarkey   = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$loc64\rarreg.key"
$rarreg32 = "$loc32\rarreg.key"

$keygen       = $null
$keygenUrl    = $null
$keygen64     = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32     = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygenUrl32  = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x86.exe"
$keygenUrl64  = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x64.exe"

$server1_host = "www.rarlab.com"
$server1      = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2      = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

$KNOWN_VERSIONS = @(713, 712, 711, 710, 701, 700, 624, 623, 622, 621, 620, 611, 610, 602, 601, 600, 591, 590, 580, 571, 570, 561, 560, 550, 540, 531, 530, 521, 520, 511, 510, 501, 500, 420, 411, 410, 401, 400, 393, 390, 380, 371, 370, 360, 350, 340, 330, 320, 310, 300, 290)
$LANG_CODE_LIST = @("ar","al","am","az","by","ba","bg","bur","ca","sc","tc","cro","cz","dk","nl","en","eu","est","fi","fr","gl","d","el","he","hu","id","it","jp","kr","lt","mk","mn","no","prs","pl","pt","br","ro","ru","srbcyr","srblat","sk","slv","es","ln","esco","sw","th","tr","uk","uz","va","vn")
$LANG_NAME_LIST = @("Arabic","Albanian","Armenian","Azerbaijani","Belarusian","Bosnian","Bulgarian","Burmese (Myanmar)","Catalan","Chinese Simplified","Chinese Traditional","Croatian","Czech","Danish","Dutch","English","Euskera","Estonian","Finnish","French","Galician","German","Greek","Hebrew","Hungarian","Indonesian","Italian","Japanese","Korean","Lithuanian","Macedonian","Mongolian","Norwegian","Persian","Polish","Portuguese","Portuguese Brazilian","Romanian","Russian","Serbian Cyrillic","Serbian Latin","Slovak","Slovenian","Spanish","Spanish (Latin American)","Spanish Colombian","Swedish","Thai","Turkish","Ukrainian","Uzbek","Valencian","Vietnamese")

$default_lang_code = 'en'
$default_lang_name = 'English'

$link_freedom_universe_yt    = "https://youtu.be/OD_WIKht0U0?t=450"
$link_overwriting            = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"
$link_howtouse               = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_configuration          = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_endof32bitsupport      = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$OLDEST                      = 290
$LATEST                      = $KNOWN_VERSIONS[0]
$FIRST_64BIT                 = 390
$LATEST_32BIT                = 701
$LATEST_OLD_WRAR             = 611

# --- SWITCH / CONFIGS ---
$script:custom_name          = $null
$script:custom_code          = $null
$script:SCRIPT_NAME_LOCATION = $null

$script:WINRAR_EXE           = $null
$script:FETCH_WINRAR         = $false             # Download standard WinRAR
$script:FETCH_WRAR           = $false             # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED  = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:CUSTOM_INSTALLATION  = $false
$script:DOWNLOAD_ONLY        = $false
$script:DOWNLOAD_WINRAR      = $false
$script:KEEP_DOWNLOAD        = $false

$script:licensee             = $null
$script:license_type         = "Single User License"
$script:LICENSE_ONLY         = $false             # SKIP INSTALLATION
$script:CUSTOM_LICENSE       = $false
$script:SKIP_LICENSING       = $false             # INSTALL ONLY
$script:OVERWRITE_LICENSE    = $false

$script:ARCH                 = $null              # Download architecture
$script:RARVER               = $null              # WinRAR version
$script:TAGS                 = $null              # Other download types, i.e. beta, language
# --- END SWITCH / CONFIGS ---
#endregion

#region General Messages
$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_UnknownError = {
  Stop-OcwrOperation -ExitType Error -Message "An unknown error occured."
}

$Error_WinrarNotInstalled = {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR is not installed."
}

$Error_NoInternetConnection = {
  New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."
  Stop-OcwrOperation -ExitType Error -Message "Internet connection lost or unavailable."
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}

$Error_UnableToProcess = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR data is invalid."
}

$Error_UnableToProcessSpecialCode = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process special code" -ToastText "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Unable to process special code."
}
#endregion

#region Licensing Messages
$Error_LicenseExists = {
  New-Toast -LongerDuration -ToastTitle "Unable to license WinRAR" -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_ButLicenseExists = {
  New-Toast -LongerDuration -ToastTitle "WinRAR installed successfully but.." -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_BinFolderMissing = {
  New-Toast -ActionButtonUrl $link_howtouse -ToastTitle "Missing `"bin`" folder" -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."
  Stop-OcwrOperation -ExitType Warning -Message "Missing `"bin`" folder"
}
#endregion

#region Install Messages
$Error_No32bitSupport = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "No 32-bit support for this version of WinRAR."
}

$Error_InvalidVersionNumber = {
  New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number provided is greater than the latest version available."
  Stop-OcwrOperation -ExitType Error -Message "Invalid version number."
}

$Error_UnableToConnectToDownload = {
  New-Toast -ToastTitle "Unable to make a connection" -ToastText "Please check your internet or firewall rules."
  Stop-OcwrOperation -ExitType Error -Message "Unable to make a connection."
}
#endregion

#region Uninstall Messages
$UninstallSuccess = {
  New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."
  Stop-OcwrOperation -ExitType Complete
}

$UnlicenseSuccess = {
  New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
  Stop-OcwrOperation -ExitType Complete
}

$Error_UninstallerMissing = {
  New-Toast -ToastTitle "WinRAR uninstaller is missing" -ToastText "WinRAR may not be installed correctly." -ToastText2 "Verify installation at $($rarloc)"
  Stop-OcwrOperation -ExitType Error -Message "WinRAR uninstaller is missing"
}

$Error_UnlicenseFailed = {
  New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."
  Stop-OcwrOperation -ExitType Error -Message "No license found."
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

function Set-DefaultArchVersion {
  <#
    .DESCRIPTION
      Set config defaults.
  #>
  if ($null -eq $script:ARCH) {
    Write-Info "Using default 64-bit architecture"
    $script:ARCH = "x64"
  }
  if ($null -eq $script:RARVER) {
    Write-Info "Using default version $(Format-Text $(Format-VersionNumber $LATEST) -Foreground White -Formatting Underline)"
    $script:RARVER = $LATEST
  }
  if ($null -eq $script:TAGS) {
    Write-Info "WinRAR language set to $(Format-Text $default_lang_name -Foreground White -Formatting Underline)"
  }
}
#endregion

#region Data Processing
function Get-LanguageName {
  <#
    .DESCRIPTION
      Return the full language name based on the code provided in the
      configuration via TAGS.

    .PARAMETER LangCode
      Specify a language code to get the name of.
  #>
  Param(
    [Parameter(Mandatory=$false)][string]$LangCode,
    [switch]$Quiet
  )

  # if ([string]::IsNullOrEmpty($script:TAGS)) { return $null } # leaving this here JIC
  if ([string]::IsNullOrEmpty($LangCode)) { $LangCode = $script:TAGS }

  $extractedLangCode = $null
  $betaCodeMatch = [regex]::matches($LangCode, 'b\d+')

  if ($betaCodeMatch.Count -gt 0) {
    $extractedLangCode = $LangCode.Trim($betaCodeMatch[0].Value)
  } else {
    $extractedLangCode = $LangCode # LangCode has the language code.
  }

  $defaultTags = {
    $script:TAGS = if ($betaCodeMatch.Count -gt 0) { $betaCodeMatch[0].Value } else { $null }
    (Get-LanguageName -LangCode $default_lang_code)
  }

  # If the extracted language code is null or empty (e.g., if $script:TAGS was
  # "b1", Trim("b1") results in ""), then it's not a valid code to search for.
  if ([string]::IsNullOrEmpty($extractedLangCode)) {
    # This verification will be handled by Confirm-DownloadConfig
    # In theory, this block should only be visited once throughout the runtime
    # of the program
    return &$defaultTags
  }

  # idiot prevention
  if ($extractedLangCode -eq 'en') {
    $script:TAGS = if ($betaCodeMatch.Count -gt 0) { $betaCodeMatch[0].Value } else { $null }
    return 'English'
  }

  $position = 0
  $isFound = $false

  # Iterate through the known language codes to find a match.
  foreach ($code in $LANG_CODE_LIST) {
    if ($code -eq $extractedLangCode) {
      $isFound = $true
      break
    }
    $position++
  }

  if ($isFound) {
    if ($position -lt $LANG_NAME_LIST.Count) {
      return $LANG_NAME_LIST[$position] # return the language name
    } else {
      # "Internal error: Language code found, but index $position is out of
      # bounds for LANG_NAME_LIST."
      if (-not $Quiet) { Write-Error "Unable to process language requirements. Using default language." }
      return &$defaultTags
    }
  } else {
    if (-not $Quiet) { Write-Info "Requested language not found. Using default language." }
    return &$defaultTags
  }
}

function Get-SpecialCode {
  <#
    .SYNOPSIS
      Enable or execute actions based on a specified code.

    .DESCRIPTION
      Determine the specified prerequisite action or extra functions requested
      by the user.

      List of code functions:
        0 --- Uninstall WinRAR and exit.
        1 --- Unlicense the selected WinRAR installation.
        2 --- Only install WinRAR; do not license.
        3 --- Only license WinRAR; do not install.

    .EXAMPLE
      one-cl0ckrar.cmd
        --- No further action will be taken after uninstallation is completed
      onecl3ckrar_620.cmd   --- WinRAR 6.20 will not be installed

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>

  if ($script:custom_name -match 'click' -and -not [string]::IsNullOrEmpty([regex]::matches($script:custom_name, '\d+')[0].Value)) {
    &$Error_UnableToProcessSpecialCode
  }
  $script:custom_code = ([regex]::matches($script:custom_name, '\d+'))[0].Value
  if ($null -eq $script:custom_code) { return }

  $rarloc = $script:WINRAR_INSTALLED_LOCATION

  switch ($script:custom_code) {
    0 {
      if ($script:WINRAR_IS_INSTALLED) {
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
      } else { &$Error_WinrarNotInstalled }
    }
    1 {
      Write-Host -NoNewLine "Un-licensing WinRAR... "
      if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
        Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
        New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
        &$UnlicenseSuccess
      } else { &$Error_UnlicenseFailed }
    }
    2 { $script:SKIP_LICENSING = $true; break }
    3 { $script:LICENSE_ONLY   = $true; break }
    default {
      Write-Warn "Custom code function `"$script:custom_code`" was not found."
      Confirm-QueryResult -ExpectNegative `
        -Query "Proceed as normal without custom code?" `
        -ResultPositive {
          Write-Info "User confirmed ignore code function. Proceeding as normal."
          return
        } `
        -ResultNegative {
          New-Toast -ActionButtonUrl "$link_configuration" `
                    -ToastTitle "Custom Code Error" `
                    -ToastText "Code `"$script:custom_code`" is not an option" `
                    -ToastText2 "Check the script name for any typos and try again."
          Stop-OcwrOperation -ExitType Error
        }
    }
  }
}

function Confirm-ScriptNamePosition {
  <#
    .SYNOPSIS
      Verify and validate the script name.

    .DESCRIPTION
      Verifies the position of the script name from a custom config.
      The script name is at either position [0] or position [2].
      Extra verification is done to ensure that a valid script name exists.

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>
  Param($Config)

  $position = 0

  foreach ($data in $Config) {
    $data = $data.Value

    if ($position -notin (0,1,2)) {
      # 0     --- General use
      # 1, 2  --- Licensing requetsed
      $position++  # Increment conceptual position
      continue     # Skip this data item
    }

    $one = ([regex]::matches($data, 'one')).Count -gt 0
    $rar = ([regex]::matches($data, 'rar')).Count -gt 0
    $d_code = ([regex]::matches($data, '\d{1}')).Count -gt 0
    $i_char = ([regex]::matches($data, 'i')).Count -gt 0

    if ($one -and $rar) {
      if (($i_char -and $d_code) -or (-not $i_char -and -not $d_code)) {
        &$Error_UnknownScript; exit
      }
      $script:custom_name = $data # Assign the STRING value
      $script:SCRIPT_NAME_LOCATION = $position
      break
    }
    else {
      $position++  # Increment conceptual position
    }
  }

  if ($null -eq $script:custom_name) {
    &$Error_UnknownScript; exit
  }
}

function Confirm-SpecialSwitch {
  <#
    .SYNOPSIS
      Verify and enable special functions.

    .DESCRIPTION
      Verifies whether or not an special function was specified by `-one-` or
      `-rar` and then enables the respective function.

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>

  $switch_one = ([regex]::matches($script:custom_name, 'one-')).Count -gt 0
  $switch_rar = ([regex]::matches($script:custom_name, '-rar')).Count -gt 0

  if ($switch_one -and $switch_rar) {
    $script:custom_name = $script_name_download_only_overwrite
  } elseif ($switch_one) {
    $script:custom_name = $script_name_download_only
  } elseif ($switch_rar) {
    $script:custom_name = $script_name_overwrite
  } else {
    $script:custom_name = $script_name
  }
}

function Get-DataFromConfig {
  <#
    .SYNOPSIS
      Retrieve the config data.

    .DESCRIPTION
      Copy custom specified license and installation configuration data
      based on the position of the script name.

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>
  Param($Config)

  if ($null -eq $Config.Count -or $null -eq $script:SCRIPT_NAME_LOCATION -or $script:SCRIPT_NAME_LOCATION -notin (0,1,2)) {
    &$Error_UnableToProcess
  }
  if ($script:SCRIPT_NAME_LOCATION -eq 0) {
    # Download/install
    # e.g. oneclickrar_x64_700.cmd
    if ($Config.Count -gt 1 -and $Config.Count -le 4) {                         # GET DOWNLOAD-ONLY DATA
      $script:CUSTOM_INSTALLATION = $true
      # `$Config[0]` is the script name # 1
      $script:ARCH   = $Config[1].Value # 2
      $script:RARVER = $Config[2].Value # 3                                     # Not required for download
      $script:TAGS   = $Config[3].Value # 4                                     # Not required for download
    }
    elseif (-not($script:LICENSE_ONLY -or $script:SKIP_LICENSING -or $script:DOWNLOAD_ONLY)) {
      &$Error_TooManyArgs
    }
  }
  elseif ($script:SCRIPT_NAME_LOCATION -eq 1) {
    # Download/install, license
    if ($Config.Count -gt 1 -and $Config.Count -eq 2) {                         # GET LICENSE-ONLY DATA
      # e.g. John Doe_oneclickrar.cmd
      $script:CUSTOM_LICENSE = $true
      $script:licensee       = $Config[0].Value # 1
      # `$Config[1]` is the script name         # 2
      # $script:license_type => Default license type
    }
    elseif ($Config.Count -ge 3 -and $Config.Count -le 5) {                     # GET DOWNLOAD AND LICENSE DATA
      # e.g. John Doe_oneclickrar_x64_700_ru.cmd
      $script:CUSTOM_LICENSE = $true
      $script:CUSTOM_INSTALLATION = $true
      $script:licensee       = $Config[0].Value # 1
      # `$Config[1]` is the script name         # 2
      # $script:license_type => Default license type
      $script:ARCH   = $Config[2].Value # 3
      $script:RARVER = $Config[3].Value # 4                                     # Not required for download
      $script:TAGS   = $Config[4].Value # 5                                     # Not required for download
    }
    else { &$Error_TooManyArgs }
  }
  elseif ($script:SCRIPT_NAME_LOCATION -eq 2) {
    # Download/install, license
    if ($Config.Count -gt 1 -and $Config.Count -eq 3) {                     # GET LICENSE-ONLY DATA
      # e.g. John Doe_License_oneclickrar.cmd
      $script:CUSTOM_LICENSE = $true
      $script:licensee       = $Config[0].Value # 1
      $script:license_type   = $Config[1].Value # 2
      # `$Config[2]` is the script name         # 3
    }
    elseif ($Config.Count -ge 4 -and $Config.Count -le 6) {                     # GET DOWNLOAD AND LICENSE DATA
      # e.g. John Doe_License_oneclickrar_x64_700_ru.cmd
      $script:CUSTOM_LICENSE = $true
      $script:CUSTOM_INSTALLATION = $true
      $script:licensee       = $Config[0].Value # 1
      $script:license_type   = $Config[1].Value # 2
      # `$Config[2]` is the script name # 3
      $script:ARCH   = $Config[3].Value # 4
      $script:RARVER = $Config[4].Value # 5                                     # Not required for download
      $script:TAGS   = $Config[5].Value # 6                                     # Not required for download
    }
    else { &$Error_TooManyArgs }
  } else { &$Error_UnableToProcess }
}

function Set-OcwrOperationMode {
  <#
    .SYNOPSIS
      Determine the primary operation mode.

    .DESCRIPTION
      This function determines the primary operation mode based on
      $script:custom_name, which would have been standardized by
      `Confirm-SpecialSwitch` if it was a variant.

      If $script:custom_name still contains a special code (e.g. "onecl0ckrar"),
      it will fall to the 'default' case here if not matched by specific
      variants. The special code itself is handled by `Get-SpecialCode`.

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>

  switch ($script:custom_name) {
    $script_name { break }
    $script_name_overwrite {
      $script:OVERWRITE_LICENSE = $true
      break
    }
    $script_name_download_only {
      $script:DOWNLOAD_ONLY = $true
      $script:KEEP_DOWNLOAD = $true
      break
    }
    $script_name_download_only_overwrite {
      $script:OVERWRITE_LICENSE = $true
      # When both overwrite and download-only is set, the function is changed
      # to keep the download but allow installation
      $script:DOWNLOAD_ONLY = $false
      $script:KEEP_DOWNLOAD = $true
      break
    }
    default { &$Error_UnknownScript }
  }
}

function Confirm-DownloadConfig {
  <#
    .DESCRIPTION
      Verify and validate download config data and reorder to correct data
      positions before executing any subsequent actions.

    .NOTES
      Single reference within `Confirm-ConfigData`.
  #>
  # 1. Verify ARCH data. Copy the config to the correct variables (LIFO)
  # If ARCH has a value, but is not an architecture value
  if ($null -ne $script:ARCH -and $script:ARCH -notmatch 'x(64|32)') {
    # If the ARCH value is not RARVER, then it is TAGS
    if ($script:ARCH -notmatch '^\d{3,}$') {
      $script:TAGS = $script:ARCH
      # Defaults from here
      Write-Warn "No version provided"
      Write-Info "Using latest WinRAR version $(Format-VersionNumber $LATEST)"
      $script:RARVER = $LATEST
    }
    # If the ARCH value is RARVER
    else {
      $script:TAGS = $script:RARVER
      $script:RARVER = $script:ARCH
    }
    # Defaults from here
    Write-Warn "No architecture provided"
    if ($script:RARVER -lt $FIRST_64BIT) {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is $(Format-Text "32-bit only" -Formatting Underline)"
      Write-Info "Using 32-bit for versions older than $(Format-Text $(Format-VersionNumber $FIRST_64BIT) -Formatting Underline)"
      $script:ARCH = "x32" # Assume 32-bit
    }
    else {
      Write-Info "Using default 64-bit architecture"
      $script:ARCH = "x64" # Assume 64-bit
    }
  }

  # 2. Verify RARVER data.
  # 2.1. Confirm correct version number for 32-bit installer
  if ($script:ARCH -eq "x32") {
    if ($null -eq $script:RARVER) {
      Write-Warn "No version provided"
      Write-Info "Using latest 32-bit version $(Format-VersionNumber $LATEST_32BIT)"
      $script:RARVER = $LATEST_32BIT
    }
    elseif ($script:RARVER -gt $LATEST_32BIT) {
      Write-Warn "No 32-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)"
      Confirm-QueryResult -ExpectPositive `
        -Query "Use latest 32-bit version $(Format-VersionNumber $LATEST_32BIT)?" `
        -ResultPositive {
          Write-Info "Confirmed use of version $(Format-VersionNumber $LATEST_32BIT)"
          $script:RARVER = $LATEST_32BIT
        } `
        -ResultNegative { &$Error_No32bitSupport }
    }
  }

  # 2.2. Confirm correct version number for 64-bit installer
  if ($script:ARCH -eq "x64") {
    if ($null -eq $script:RARVER) {
      Write-Warn "No version provided"
      Write-Info "Using latest 64-bit version $(Format-VersionNumber $LATEST)"
      $script:RARVER = $LATEST
    }
    elseif ($script:RARVER -lt $FIRST_64BIT) {
      Write-Warn "No 64-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)"
      Confirm-QueryResult -ExpectPositive `
        -Query "Use earliest 64-bit version $(Format-VersionNumber $FIRST_64BIT)?" `
        -ResultPositive {
          Write-Info "Confirmed use of version $(Format-VersionNumber $FIRST_64BIT)"
          $script:RARVER = $FIRST_64BIT
        } `
        -ResultNegative {
          Confirm-QueryResult -ExpectPositive `
            -Query "Use 32-bit for version $(Format-VersionNumber $script:RARVER)?" `
            -ResultPositive {
              Write-Info "Confirmed switch to 32-bit for version $(Format-VersionNumber $script:RARVER)"
              $script:ARCH = 'x32'
            } `
            -ResultNegative { &$Error_InvalidVersionNumber }
        }
    }
  }

  # 2.3. Sanity check for RARVER
  if ($script:RARVER -match '^\d{3,}$' -and $KNOWN_VERSIONS -notcontains $script:RARVER) {
    if ($script:RARVER -gt $LATEST) {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is newer than the known latest $(Format-VersionNumber $LATEST)"
    }
    elseif ($script:RARVER -lt $OLDEST) {
      Write-Warn "Version $(Format-VersionNumber $OLDEST) is the earliest known available WinRAR version"
    }
    else {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is not a known WinRAR version"
    }

    Confirm-QueryResult -ExpectNegative `
      -Query "Attempt to retrieve unknown version $(Format-VersionNumber $script:RARVER)?" `
      -ResultPositive {
        Write-Info "Confirmed retrieval of unknown version $(Format-VersionNumber $script:RARVER)"
        Write-Warn "Version $(Format-VersionNumber $script:RARVER) may not exist on the server"
      } `
      -ResultNegative { &$Error_InvalidVersionNumber }
  }

  # 3. Verify TAGS data.
  if ($null -eq (Get-LanguageName -Quiet)) { $script:TAGS = $null } # quick patch
  if ([string]::IsNullOrEmpty($script:TAGS)) {
    Write-Info "WinRAR language set to $(Format-Text $default_lang_name -Foreground White -Formatting Underline)"
  } else {
    Write-Info "WinRAR language set to $(Format-Text $(Get-LanguageName) -Foreground White -Formatting Underline)"
  }
}

function Confirm-ConfigData {
  <#
    .SYNOPSIS
      Parse the script name and determine the type of operation.

    .DESCRIPTION
      The script name is parsed to determine the type of operation.
      There are three types of operations:
        1. Download and overwrite
        2. License and overwrite
        3. Download, license, and overwrite
  #>

  $config = [regex]::matches($CMD_NAME, '[^_]+')

  <# Step 1 #> Confirm-ScriptNamePosition $config
  <# Step 2 #> Get-SpecialCode
  <# Step 3 #> Confirm-SpecialSwitch
  <# Step 4 #> Set-OcwrOperationMode
  <# Step 5 #> Get-DataFromConfig $config
  if ($script:CUSTOM_INSTALLATION) {
    <# Opt. #> Confirm-DownloadConfig
  } else { Set-DefaultArchVersion }
}
#endregion

#region Installation
function Format-VersionNumber {
  <#
    .DESCRIPTION
      Format version numbers as x.xx
  #>
  Param($VersionNumber)
  if ($null -eq $VersionNumber) { return $null }
  return "{0:N2}" -f ($VersionNumber / 100)
}

function Format-VersionNumberFromExecutable {
  <#
    .DESCRIPTION
      Retrieve the WinRAR version form the executable name and format it.
  #>
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    $Executable,
    [Switch]$IntToDouble
  )

  $version = if ($IntToDouble) { $Executable }
             elseif ($Executable -match "(?<version>\d{3})") { $matches['version'] }
             else { return $null }
  $version = Format-VersionNumber $version
  return $version
}

function Get-LocalWinrarInstaller {
  <#
    .DESCRIPTION
      Find any WinRAR installer executables in the current directory.
  #>
  $name = $null
  $file_pattern = $null
  $name_pattern = $null

  if ($script:ARCH -eq 'x32' -and $script:RARVER -lt $LATEST_OLD_WRAR) {
    $script:FETCH_WRAR = $true
    $name = $wrar_name
    $file_pattern = $wrar_file_pattern
    $name_pattern = $wrar_name_pattern
  } else {
    $script:FETCH_WINRAR = $true
    $name = "$winrar_name-$($script:ARCH)-"
    $file_pattern = $winrar_file_pattern
    $name_pattern = $winrar_name_pattern
  }

  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match $name_pattern }

  if ($script:CUSTOM_INSTALLATION) {
    $download_pattern = "$($name)$($script:RARVER)$($script:TAGS).exe"
    foreach ($file in $files) {
      if ($file -match $download_pattern) { return $file }
    }
  } else {
    foreach ($file in $files) {
      if ($file -match $file_pattern) { return $file }
    }
  }
}

function Get-WinrarInstaller {
  <#
    .DESCRIPTION
      Download a WinRAR installer from the available servers.

    .PARAMETER HostUri
      Server domain.

    .PARAMETER HostUriDir
      Installer download path on the server.
  #>
  Param($HostUri, $HostUriDir)

  $version = Format-VersionNumber $script:RARVER
  if ($script:TAGS) {
    $beta = [regex]::matches($script:TAGS, '\d+')[0].Value
    $lang = $script:TAGS.Trim($beta).ToUpper()
  }

  Write-Host "Connecting to $HostUri... "
  if (Test-Connection "$HostUri" -Count 2 -Quiet) {
    # Verify that connection to the host is good for downloading
    try { Invoke-WebRequest -Uri $HostUri | Out-Null }
    catch { &$Error_UnableToConnectToDownload }

    Write-Host "Verifying download... "

    if ($script:FETCH_WRAR) {
      $download_url = "$HostUriDir/wrar$($script:RARVER)$($script:TAGS).exe"
    }
    else {
      $download_url = "$HostUriDir/winrar-$($script:ARCH)-$($script:RARVER)$($script:TAGS).exe"
    }

    try {
      $responseCode = $(Invoke-WebRequest -Uri $download_url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop).StatusCode
    }
    catch {
      Write-Error -Message "Unable to download." -ErrorId "404" -Category NotSpecified 2>$null
    }

    if ($responseCode -eq 200) {
      Write-Host "Downloading WinRAR $($version)$(if($beta){" Beta $beta"}) ($($script:ARCH))$(if($lang){" ($(Get-LanguageName))"})... "
      Start-BitsTransfer $download_url $pwd\ -ErrorAction SilentlyContinue
    }
    else {
      Write-Error -Message "Download unavailable." -ErrorId "404" -Category NotSpecified 2>$null
    }
  } else { &$Error_NoInternetConnection }
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

function Select-CurrentWinrarInstallation {
  <#
    .DESCRIPTION
      Select WinRAR installation directory based on the proposed installation
      architecture.
  #>
  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    switch ($script:ARCH) {
      'x64' {
        $script:WINRAR_INSTALLED_LOCATION = $loc64
        break
      }
      'x32' {
        $script:WINRAR_INSTALLED_LOCATION = $loc32
        break
      }
      default {
        Stop-OcwrOperation -ExitType Error -Message "No architecture provided"
      }
    }
  }
  Write-Info "Installation directory: $(Format-Text $($script:WINRAR_INSTALLED_LOCATION) -Foreground White -Formatting Underline)"
}

function Confirm-CurrentWinrarInstallation {
  <#
    .DESCRIPTION
      Verify and confirm the current WinRAR installation to be worked on.
  #>
  # `-iver` switch returns the version number of the current (Win)RAR installation
  $civ = $(&$script:WINRAR_INSTALLED_LOCATION\rar.exe "-iver") # current installed version
  if ("$civ" -match $(Format-VersionNumber $script:RARVER)) {
    Write-Info "This version of WinRAR is already installed: $(Format-Text $(Format-VersionNumber $script:RARVER) -Foreground White -Formatting Underline)"
    Confirm-QueryResult -ExpectNegative `
      -Query "Continue with installation?" `
      -ResultPositive {
        Write-Info "Confirmed re-installation of WinRAR version $(Format-Text $(Format-VersionNumber $script:RARVER) -Foreground White -Formatting Underline)"
      } `
      -ResultNegative { Stop-OcwrOperation }
  }
}

function Invoke-Installer($x, $v) {
  <#
    .SYNOPSIS
      Run the installer.

    .PARAMETER x
      The executable file.

    .PARAMETER v
      WinRAR version number.
  #>
  Write-Host "Installing WinRAR $v... "
  try { Start-Process $x "/s" -Wait }
  catch {
    New-Toast -ToastTitle "Installation error" -ToastText "The script has run into a problem during installation. Please restart the script."
    Stop-OcwrOperation -ExitType Error -Message "An unknown error occured."
  }
  finally {
    if (($script:FETCH_WINRAR -or $script:FETCH_WRAR) -and $script:DOWNLOAD_WINRAR -and -not $script:KEEP_DOWNLOAD) {
      Remove-Item $script:WINRAR_EXE
    }
  }
}

function Invoke-DownloadWinrarExecutable {
  <#
    .DESCRIPTION
      Download a WinRAR installer specified by the user.
  #>
  $script:DOWNLOAD_WINRAR = $true

  $Error.Clear()
  $local:retrycount = 0
  $local:version = (Format-VersionNumber $script:RARVER)

  Get-WinrarInstaller -HostUri $server1_host -HostUriDir $server1

  foreach ($wdir in $server2) {
    if ($Error) { # will catch the first error from the attempt with server 1
      $Error.Clear()
      $local:retrycount++
      Write-Host -NoNewLine "`nFailed. Retrying... $local:retrycount`n"
      Get-WinrarInstaller -HostUri $server2_host -HostUriDir $wdir
    }
  }

  if ($Error) {
    if ($script:CUSTOM_INSTALLATION) {
      New-Toast -ToastTitle "Unable to fetch download" `
                -ToastText  "WinRAR $($local:version) ($script:ARCH) may not exist on the server." `
                -ToastText2 "Check the version number and try again."
      Stop-OcwrOperation -ExitType Error -Message "Unable to fetch download. Check the version number and try again."
    } else {
      New-Toast -ToastTitle "Unable to fetch download" `
                -ToastText  "Are you still connected to the internet?" `
                -ToastText2 "Please check your internet connection."
      Stop-OcwrOperation -ExitType Error -Message "Unable to fetch download"
    }
  }
}

function Invoke-OwcrInstallation {
  <#
    .DESCRIPTION
      Installation instructions to be executed (if not disabled).
  #>
  if (-not $script:LICENSE_ONLY) {
    # This ensures that the script does not unnecessarily
    # download a new installer if one is available in the
    # current directory
    $script:WINRAR_EXE = (Get-LocalWinrarInstaller)

    # if there are no installers, proceed to download one
    if ($null -eq $script:WINRAR_EXE) {
      Invoke-DownloadWinrarExecutable
      if (-not $script:DOWNLOAD_ONLY) { Invoke-OwcrInstallation; break }
      else {
        New-Toast -ToastTitle "Download Complete" `
                  -ToastText  "WinRAR $($local:version) ($script:ARCH) was successfully downloaded." `
                  -ToastText2 "Run this script again if you ever need to install it."
        $script:WINRAR_EXE = (Get-LocalWinrarInstaller)
        Write-Info "Download saved to $(Format-Text "'$(Format-Text "$pwd\$script:WINRAR_EXE" -Formatting Underline)'" -Foreground White)"
        Stop-OcwrOperation -ExitType Complete
      }
    } else {
      Write-Info "Found executable versioned at $(Format-Text (Format-VersionNumberFromExecutable $script:WINRAR_EXE) -Foreground White -Formatting Underline)"
      if ($script:DOWNLOAD_ONLY) {
        New-Toast -ToastTitle "Download Aborted" `
                  -ToastText  "An installer for WinRAR $(Format-VersionNumberFromExecutable $script:WINRAR_EXE) ($script:ARCH) already exists." `
                  -ToastText2 "Check the requested download version and try again."
        Stop-OcwrOperation -ExitType Warning -Message "An installer for WinRAR $(Format-VersionNumberFromExecutable $script:WINRAR_EXE) ($script:ARCH) in $(Get-LanguageName) already exists"
      }
    }

    Invoke-Installer $script:WINRAR_EXE (Format-VersionNumberFromExecutable $script:WINRAR_EXE)

    # set the new installation location
    switch ($script:ARCH) {
      'x64' {
        $script:WINRAR_INSTALLED_LOCATION = $loc64
        break
      }
      'x32' {
        $script:WINRAR_INSTALLED_LOCATION = $loc64
        break
      }
    }
  }
}
#endregion

#region Licensing
function Invoke-OcwrLicensing {
  <#
    .DESCRIPTION
      Licensing instructions to be executed (if not disabled).
  #>
  if (-not $script:SKIP_LICENSING) {
    if (-not $script:LICENSE_ONLY) {
      switch ($script:ARCH) {
        'x64' {
          if (Test-Path $winrar64 -PathType Leaf) {
            $keygen = $keygen64
            $rarreg = $rarreg64
            $keygenUrl = $keygenUrl64
          }
          else {
            Write-Info "WinRAR is not installed"
            Confirm-QueryResult -ExpectNegative `
              -Query "Do you want to install WinRAR version $(Format-VersionNumber $script:RARVER)?" `
              -ResultPositive {
                $script:LICENSE_ONLY = $false
                Invoke-OwcrInstallation
              } `
              -ResultNegative { &$Error_WinrarNotInstalled }
          }
          break
        }
        'x32' {
          if (Test-Path $winrar32 -PathType Leaf) {
            $keygen = $keygen32
            $rarreg = $rarreg32
            $keygenUrl = $keygenUrl32
          }
          else {
            Write-Info "WinRAR is not installed"
            Confirm-QueryResult -ExpectNegative `
              -Query "Do you want to install WinRAR version $(Format-VersionNumber $script:RARVER)?" `
              -ResultPositive {
                $script:LICENSE_ONLY = $false
                Invoke-OwcrInstallation
              } `
              -ResultNegative { &$Error_WinrarNotInstalled }
          }
          break
        }
        default {
          &$Error_UnknownError
          break
        }
      }
    } else {
      switch ($script:WINRAR_INSTALLED_LOCATION) {
        $loc64 {
          $rarreg = $rarreg64
          $keygen = $keygen64
          $keygenUrl = $keygenUrl64
          break
        }
        $loc32 {
          $rarreg = $rarreg32
          $keygen = $keygen32
          $keygenUrl = $keygenUrl32
          break
        }
      }
    }

    # install WinRAR license
    if (-not(Test-Path $rarreg -PathType Leaf) -or $script:OVERWRITE_LICENSE) {
      if ($script:CUSTOM_LICENSE) {
        $addbinfolder = $false

        if (-not(Test-Path $keygen -PathType Leaf)) {
          $addbinfolder = $true
          if (Test-Connection "github.com" -Count 2 -Quiet) {
            $bin = "bin/winrar-keygen"
            Write-Info "'bin' folder missing. Downloading..."
            if (-not(Test-Path "./$bin" -PathType Container)) {
              New-Item -ItemType Directory -Path $bin | Out-Null
            }
            Start-BitsTransfer $keygenUrl "$pwd/$bin" -ErrorAction SilentlyContinue
          }
          else { &$Error_BinFolderMissing }
        }

        &$keygen "$($script:licensee)" "$($script:license_type)" | Out-File -Encoding utf8 $rarreg

        if ($addbinfolder) { Remove-Item "./bin" -Recurse -Force }
      }
      else {
        if (Test-Path "rarreg.key" -PathType Leaf) {
          Copy-Item -Path "rarreg.key" -Destination $rarreg -Force
        }
        else {
          [IO.File]::WriteAllLines($rarreg, $rarkey)
        }
      }
    }
    else {
      Write-Info "A WinRAR license already exists"
      Confirm-QueryResult -ExpectNegative `
        -Query "Do you want to overwrite the current license?" `
        -ResultPositive {
          $script:OVERWRITE_LICENSE = $true
          Invoke-OcwrLicensing
        } `
        -ResultNegative {
          if ($script:LICENSE_ONLY) { &$Error_LicenseExists }
          else { &$Error_ButLicenseExists }
        }
    }
  }
}
#endregion

#region Begin Execution
Write-Title

# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations

# Grab the name of the script file and process any
# configuration data set by the user
if ($CMD_NAME -ne $script_name) {
  Confirm-ConfigData
} else {
  Set-DefaultArchVersion
}

if ($script:LICENSE_ONLY) {
  Select-WinrarInstallation
}
elseif ($script:WINRAR_IS_INSTALLED -and ((-not $script:DOWNLOAD_ONLY) -or $script:OVERWRITE_LICENSE)) {
  Select-CurrentWinrarInstallation
  Confirm-CurrentWinrarInstallation
}

Invoke-OwcrInstallation

Invoke-OcwrLicensing

# --- SUCCESSFUL EXIT TOAST MESSAGES

if ($script:SKIP_LICENSING) {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed successfully" `
              -ToastText  "Freedom throughout the universe!"
} elseif ($script:LICENSE_ONLY) {
  if ($script:CUSTOM_LICENSE) {
    Write-Host "`nLicensee:`t$($script:licensee)`nLicense:`t$($script:license_type)`n"
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Licensee: $($script:licensee)`nLicense: $($script:license_type)" `
              -ToastText2 "Freedom throughout the universe!"
  } else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Freedom throughout the universe!"
  }
} elseif ($script:CUSTOM_LICENSE) {
    Write-Host "`nLicensee:`t$($script:licensee)`nLicense:`t$($script:license_type)`n"
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Licensee: $($script:licensee)`nLicense: $($script:license_type)" `
              -ToastText2 "Freedom throughout the universe!"
} else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Freedom throughout the universe!"
}

Stop-OcwrOperation -ExitType Complete
#endregion

<### has bugs. maybe continue work on this in version 0.13.0 or later
$exit_Url = $link_freedom_universe_yt
$exit_ToastTitle = "WinRAR installed successfully"
$exit_ToastText = "Freedom throughout the universe!"
$exit_ToastText2 = $null

$exit_ToastTitle = "WinRAR$( `
if(-not $script:LICENSE_ONLY){" installed "} `
if(-not ($script:SKIP_LICENSING -or $script:LICENSE_ONLY)){"and"} `
if($script:LICENSE_ONLY -or $script:CUSTOM_LICENSE){" licensed "} `
)successfully"
if ($script:CUSTOM_LICENSE) { $exit_ToastText2 = $exit_ToastText; $exit_ToastText = "Licensed to `"$($script:licensee)`""}
New-Toast -Url $exit_Url -ToastTitle $exit_ToastTitle -ToastText  $exit_ToastText -ToastText2 $exit_ToastText2; exit
#>
