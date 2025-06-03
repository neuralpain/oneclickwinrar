<# :# DO NOT REMOVE THIS LINE

:: oneclickrar.cmd
:: Last updated @ v0.12.0.711 [beta.2 250517]
:: Copyright (c) 2023, neuralpain
:: Install and license WinRAR

@echo off
title oneclickrar (v0.12.0.711)
rem mode 48,12

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

# https://www.rarlab.com/rar/winrar-x64-711.exe
# https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-711.exe
# https://www.win-rar.com/fileadmin/winrar-versions/en/20253103/wrr/winrar-x64-711.exe

<#
  .SYNOPSIS
  Install and license WinRAR Archiver.

  .DESCRIPTION
  oneclickrar.cmd is a combination of installrar.cmd and
  licenserar.cmd but there are some small modifications to
  that were made to allow the two scripts to work together
  as a single unit.
#>

$global:ProgressPreference = "SilentlyContinue"
# ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -contains "S-1-5-32-544"
# ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

$script_name                         = "oneclickrar"
$script_name_overwrite               = "oneclick-rar"
$script_name_download_only           = "one-clickrar"
$script_name_download_only_overwrite = "one-click-rar"

# catch any version for any language
$winrar_name         = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# catch the old version of WinRAR for any language
$wrar_name           = "wrar"
$wrar_name_pattern   = "^wrar"
$wrar_file_pattern   = "wrar\d{3}\w*\.exe"

$rarreg   = $null
$rarkey   = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$env:ProgramFiles\WinRAR\rarreg.key"
$rarreg32 = "${env:ProgramFiles(x86)}\WinRAR\rarreg.key"

$rarloc   = $null
$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$loc96    = "x96"
$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$keygen   = $null
$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"

$server1_host = "www.rarlab.com"
$server1      = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2      = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

$KNOWN_VERSIONS = @(290, 300, 310, 320, 330, 340, 350, 360, 370, 371, 380, 390, 393, 400, 401, 410, 411, 420, 500, 501, 510, 511, 520, 521, 530, 531, 540, 550, 560, 561, 570, 571, 580, 590, 591, 600, 601, 602, 610, 611, 620, 621, 622, 623, 624, 700, 701, 710, 711)
$LANG_CODE_LIST = @("ar","al","am","az","by","ba","bg","bur","ca","sc","tc","cro","cz","dk","nl","-","eu","est","fi","fr","gl","d","el","he","hu","id","it","jp","kr","lt","mk","mn","no","prs","pl","pt","br","ro","ru","srbcyr","srblat","sk","slv","es","ln","esco","sw","th","tr","uk","uz","va","vn")
$LANG_NAME_LIST = @("Arabic","Albanian","Armenian","Azerbaijani","Belarusian","Bosnian","Bulgarian","Burmese (Myanmar)","Catalan","Chinese Simplified","Chinese Traditional","Croatian","Czech","Danish","Dutch","English","Euskera","Estonian","Finnish","French","Galician","German","Greek","Hebrew","Hungarian","Indonesian","Italian","Japanese","Korean","Lithuanian","Macedonian","Mongolian","Norwegian","Persian","Polish","Portuguese","Portuguese Brazilian","Romanian","Russian","Serbian Cyrillic","Serbian Latin","Slovak","Slovenian","Spanish","Spanish (Latin American)","Spanish Colombian","Swedish","Thai","Turkish","Ukrainian","Uzbek","Valencian","Vietnamese")

$link_freedom_universe_yt = "https://youtu.be/OD_WIKht0U0?t=450"
$link_overwriting         = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"
$link_howtouse            = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_customization       = "https://github.com/neuralpain/oneclickwinrar#customization"
$link_endof32bitsupport   = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$OLDEST                      = 290
$LATEST                      = 711
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
$script:license_type         = $null
$script:LICENSE_ONLY         = $false             # SKIP INSTALLATION
$script:CUSTOM_LICENSE       = $false
$script:SKIP_LICENSING       = $false             # INSTALL ONLY
$script:OVERWRITE_LICENSE    = $false

$script:ARCH                 = $null              # Download architecture
$script:RARVER               = $null              # WinRAR version
$script:TAGS                 = $null              # Other download types, i.e. beta, language
# --- END SWITCH / CONFIGS ---

$printvariables = {
  Write-Host "custom_name: $script:custom_name"
  Write-Host "custom_code: $script:custom_code"
  Write-Host "WINRAR_EXE: $script:WINRAR_EXE"
  Write-Host "FETCH_WINRAR: $script:FETCH_WINRAR"
  Write-Host "FETCH_WRAR: $script:FETCH_WRAR"
  Write-Host "WINRAR_IS_INSTALLED: $script:WINRAR_IS_INSTALLED"
  Write-Host "CUSTOM_INSTALLATION: $script:CUSTOM_INSTALLATION"
  Write-Host "DOWNLOAD_ONLY: $script:DOWNLOAD_ONLY"
  Write-Host "KEEP_DOWNLOAD: $script:KEEP_DOWNLOAD"
  Write-Host "licensee: $script:licensee"
  Write-Host "license_type: $script:license_type"
  Write-Host "LICENSE_ONLY: $script:LICENSE_ONLY"
  Write-Host "CUSTOM_LICENSE: $script:CUSTOM_LICENSE"
  Write-Host "SKIP_LICENSING: $script:SKIP_LICENSING"
  Write-Host "OVERWRITE_LICENSE: $script:OVERWRITE_LICENSE"
  Write-Host "ARCH: $script:ARCH"
  Write-Host "RARVER: $script:RARVER"
  Write-Host "TAGS: $script:TAGS"
  Write-Host "SCRIPT_NAME_LOCATION: $script:SCRIPT_NAME_LOCATION"
}

# check if WinRAR is installed before begin

function Get-InstalledWinrarLocations {
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
  if ($null -eq $script:ARCH) {
    Write-Info "Using default `"x64`" architecture."
    $script:ARCH = "x64"
  }
  if ($null -eq $script:RARVER) {
    Write-Info "Using default version $($LATEST)."
    $script:RARVER = $LATEST
  }
  if ($null -eq $script:TAGS) {
    Write-Info "WinRAR language set to: $(Format-Text "English" -Foreground White -Formatting Underline)."
    $script:RARVER = $LATEST
  }
}

$Error_UnknownScript = { New-Toast -LongerDuration -ActionButtonUrl "$link_customization" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again." }
$Error_TooManyParams = { New-Toast -ActionButtonUrl "$link_customization" -ToastTitle "Too many parameters" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again." }
$Error_No32bitSupport = { New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again." }
$Error_UnableToProcess = { New-Toast -ActionButtonUrl "$link_customization" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again." }
$Error_UnableToProcessSpecialCode = { New-Toast -ActionButtonUrl "$link_customization" -ToastTitle "Unable to process special code" -ToastText "Check your configuration for any errors or typos and try again." }
# $Error_InvalidArchitecture = { New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR architecture is invalid." -ToastText2 "Only x64 and x32 are supported." }
# $Error_InvalidVersionNumber = { New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number must have 3 digits." }
$Error_InvalidVersionNumber = { New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number provided is greater than the latest version available." }

# --- UTILITY

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

function Write-Info {
  Param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "INFO: $Message" -ForegroundColor DarkCyan
}

function Write-Warn {
  Param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "WARN: $Message" -ForegroundColor Yellow
}

function Write-Err {
  Param([Parameter(Mandatory=$true, Position=0)][ValidateNotNullOrEmpty()][string]$Message)
  Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Stop-OcwrOperation {
  Param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$ExitType,
    [scriptblock]$ScriptBlock
  )

  switch ($ExitType) {
    Terminate { Write-Host "Operation terminated with NORMAL." } # i don't know why this is still here but it doesn't affect operation
    Error { Write-Host "Operation terminated with ERROR." -ForegroundColor Red }
    Warning { Write-Host "Operation terminated with WARNING." -ForegroundColor Yellow }
    Complete { Write-Host "Operation completed successfully." -ForegroundColor Green }
    default { Write-Host "Operation terminated." }
  }

  &$ScriptBlock
  Pause; exit
}

function Confirm-QueryResult {
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
    if ([string]::IsNullOrEmpty($q) -or $q -match '(Y|y)') {
      if ($ResultPositive) { & $ResultPositive }
    } else {
      if ($ResultNegative) { & $ResultNegative }
    }
  }
  elseif($ExpectNegative){
    if ([string]::IsNullOrEmpty($q) -or $q -match '(N|n)') {
      if ($ResultNegative) { & $ResultNegative }
    } else {
      if ($ResultPositive) { & $ResultPositive }
    }
  }
  else {
    Write-Err "Nothing to expect."
    Stop-OcwrOperation -ExitType Error
  }
}

# --- DATA PROCESSING

# A function that is only contains a single one-line easy-to-understand command
# which is only used once should be a statement
# function Confirm-VersionNumber {
#   return ($KNOWN_VERSIONS -contains $script:RARVER)
# }

function Get-LanguageName {
  if ([string]::IsNullOrEmpty($script:TAGS)) { return $null }

  $extractedLangCode = $null
  $regexMatches = [regex]::matches($script:TAGS, 'b\d+')

  if ($regexMatches.Count -gt 0) {
    $extractedLangCode = $script:TAGS.Trim($regexMatches[0].Value)
  } else {
    $extractedLangCode = $script:TAGS # TAGS is the language code.
  }

  # If the extracted language code is null or empty (e.g., if $script:TAGS was "b1", Trim("b1") results in ""),
  # then it's not a valid code to search for.
  if ([string]::IsNullOrEmpty($extractedLangCode)) { return $null }

  $position = 0
  $isFound = $false

  # Iterate through the known language codes to find a match.
  foreach ($code in $LANG_CODE_LIST) {
    if ($code -eq $extractedLangCode) {
      $isFound = $true
      break # Exit loop once found
    }
    $position++
  }

  if ($isFound) {
    if ($position -lt $LANG_NAME_LIST.Count) {
      return $LANG_NAME_LIST[$position]
    } else {
      # "Internal error: Language code found, but index $position is out of bounds for LANG_NAME_LIST."
      return $null
    }
  } else {
    return $null
  }
}

function Get-SpecialCode {
  # REVIEW - DEBUGGING NAME: onecl0ckrar, test_script_onecl0ckrar
  if ($script:custom_name -match 'click' -and -not [string]::IsNullOrEmpty([regex]::matches($script:custom_name, '\d+')[0].Value)) { &$Error_UnableToProcessSpecialCode; exit }
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
          $script:WINRAR_IS_INSTALLED = $false # unnecessary to add this here but logically correct
          Stop-OcwrOperation -ExitType Complete -ScriptBlock {
            New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."
          }
        } else {
          New-Toast -ToastTitle "WinRAR uninstaller is missing" -ToastText "WinRAR may not be installed correctly." -ToastText2 "Verify installation at $($rarloc)"
          Stop-OcwrOperation -ExitType Error
        }
      } else {
        New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."
        Stop-OcwrOperation
      }
    }
    1 {
      Write-Host -NoNewLine "Un-licensing WinRAR... "
      if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
        Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
        New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
        Stop-OcwrOperation -ExitType Complete
      } else {
        New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."
        Stop-OcwrOperation -ExitType Error
      }
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
          Stop-OcwrOperation -ExitType Error -ScriptBlock {
            New-Toast -ActionButtonUrl "$link_customization" `
                      -ToastTitle "Custom Code Error" `
                      -ToastText "Code `"$script:custom_code`" is not an option" `
                      -ToastText2 "Check the script name for any typos and try again."
          }
        }
    }
  }
}

function Confirm-ScriptNamePosition {
  Param($Config)

  $position = 0

  foreach ($data in $Config) {
    $data = $data.Value

    if ($position -notin (0, 2)) {
      $position++  # Increment conceptual position
      continue      # Skip this data item
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
  Param($Config)

  if ($null -eq $Config.Count -or $null -eq $script:SCRIPT_NAME_LOCATION -or $script:SCRIPT_NAME_LOCATION -notin (0,2)) {
    &$Error_UnableToProcess; exit
  }
  if ($script:SCRIPT_NAME_LOCATION -eq 0) {
    # Download, and overwrite
    # e.g. oneclick-rar.cmd
    # e.g. oneclickrar_x64_700.cmd
    if ($Config.Count -gt 1 -and $Config.Count -le 4) {                         # GET DOWNLOAD-ONLY DATA
      $script:CUSTOM_INSTALLATION = $true
      # `$Config[0]` is the script name # 1
      $script:ARCH   = $Config[1].Value # 2
      $script:RARVER = $Config[2].Value # 3                                     # Not required for download
      $script:TAGS   = $Config[3].Value # 4                                     # Not required for download
    }
    elseif ($Config.Count -ne 1) {
      &$Error_TooManyParams; exit
    }
  }
  elseif ($script:SCRIPT_NAME_LOCATION -eq 2) {
    # License, download, and overwrite
    # e.g. John Doe_License_oneclickrar.cmd
    # e.g. John Doe_License_oneclickrar_x64_700.cmd
    if ($Config.Count -gt 1 -and $Config.Count -eq 3) {                         # GET LICENSE-ONLY DATA
      $script:CUSTOM_LICENSE = $true
      $script:licensee       = $Config[0].Value # 1
      $script:license_type   = $Config[1].Value # 2
      # `$Config[2]` is the script name         # 3
    }
    elseif ($Config.Count -ge 4 -and $Config.Count -le 6) {                     # GET DOWNLOAD AND LICENSE DATA
      $script:CUSTOM_LICENSE  = $true
      $script:CUSTOM_INSTALLATION = $true
      $script:licensee        = $Config[0].Value # 1
      $script:license_type    = $Config[1].Value # 2
      # `$Config[2]` is the script name # 3
      $script:ARCH   = $Config[3].Value # 4
      $script:RARVER = $Config[4].Value # 5                                     # Not required for download
      $script:TAGS   = $Config[5].Value # 6                                     # Not required for download
    }
    else {
      &$Error_TooManyParams; exit
    }
  } else {
    &$Error_UnableToProcess; exit
  }
}

function Set-OcwrOperationMode {
  <#
  .SYNOPSIS
  Determine the primary operation mode.

  .DESCRIPTION
  This function determines the primary operation mode based on $script:custom_name,
  which would have been standardized by Confirm-SpecialSwitch if it was a variant.

  If $script:custom_name still contains a special code (e.g. "onecl0ckrar"),
  it will fall to the 'default' case here if not matched by specific variants.
  The special code itself is handled by Get-SpecialCode.
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
      # when both overwrite and download-only is set, the function is changed
      # to keep the download but allow installation
      $script:DOWNLOAD_ONLY = $false
      $script:KEEP_DOWNLOAD = $true
      break
    }
    default { &$Error_UnknownScript; exit }
  }
}

function Confirm-DownloadConfig {
  if ($script:CUSTOM_INSTALLATION) {
    # 1. Verify ARCH data. Copy the config to the correct variables (LIFO)
    # If ARCH has a value, but is not an architecture value
    if ($null -ne $script:ARCH -and $script:ARCH -notmatch 'x(64|32)') {
      # If the ARCH value is not RARVER, then it is TAGS
      if ($script:ARCH -notmatch '^\d{3,}$') {
        # REVIEW - DEBUGGING NAME: oneclickrar_b1ru
        $script:TAGS = $script:ARCH
        # Defaults from here
        Write-Warn "No version provided."
        Write-Info "Using latest WinRAR verison $(Format-VersionNumber $LATEST)."
        $script:RARVER = $LATEST
      }
      # If the ARCH value is RARVER
      else {
        # REVIEW - DEBUGGING NAME: oneclickrar_100_ru
        $script:TAGS = $script:RARVER
        $script:RARVER = $script:ARCH
      }
      if (-not [string]::IsNullOrEmpty($script:TAGS)) {
        Write-Info "WinRAR language set to: $(Format-Text $(Get-LanguageName) -Foreground White -Formatting Underline)."
      }
      # Defaults from here
      Write-Warn "No architecture provided."
      if ($script:RARVER -lt $FIRST_64BIT) {
        Write-Warn "Version $(Format-VersionNumber $script:RARVER) is $(Format-Text "32-bit only" -Formatting Underline)."
        Write-Info "Using 32-bit for versions older than $(Format-Text $(Format-VersionNumber $FIRST_64BIT) -Foreground Red)."
        $script:ARCH = "x32" # Assume 32-bit
      }
      else {
        # Write-Info "Architecture will be set to 64-bit." # feels like double the message
        Write-Info "Using default `"x64`" architecture."
        $script:ARCH = "x64" # Assume 64-bit
      }
    }
    <# This if statement is not necessary
    if ($script:ARCH -ne "x64" -and $script:ARCH -ne "x32") { &$Error_InvalidArchitecture; exit }
    #>
    # Confirm correct varsion number for 32-bit installer
    if ($script:ARCH -eq "x32" -and $script:RARVER -gt $LATEST_32BIT) {
      Write-Warn "No 32-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)."
      Confirm-QueryResult -ExpectPositive `
        -Query "Use latest 32-bit version $(Format-VersionNumber $LATEST_32BIT)?" `
        -ResultPositive {
          Write-Info "User confirmed use of version $(Format-VersionNumber $LATEST_32BIT)."
          $script:RARVER = $LATEST_32BIT
        } `
        -ResultNegative {
          &$Error_No32bitSupport
          Stop-OcwrOperation -ExitType Error
        }
    }
    if ($script:ARCH -eq "x64" -and $script:RARVER -lt $FIRST_64BIT) {
      Write-Warn "No 64-bit installer available for WinRAR $(Format-VersionNumber $script:RARVER)."
      Confirm-QueryResult -ExpectPositive `
        -Query "Use earliest 64-bit version $(Format-VersionNumber $FIRST_64BIT)?" `
        -ResultPositive {
          Write-Info "User confirmed use of version $(Format-VersionNumber $FIRST_64BIT)."
          $script:RARVER = $FIRST_64BIT
        } `
        -ResultNegative {
          Confirm-QueryResult -ExpectPositive `
            -Query "Use 32-bit for version $(Format-VersionNumber $script:RARVER)?" `
            -ResultPositive {
              Write-Info "User confirmed switch to 32-bit for version $(Format-VersionNumber $script:RARVER)."
              $script:ARCH = 'x32'
            } `
            -ResultNegative {
              &$Error_InvalidVersionNumber
              Stop-OcwrOperation -ExitType Error
            }
        }
    }
    # 2. Verify version number in RARVER
    if ($script:RARVER -match '^\d{3,}$' -and $KNOWN_VERSIONS -notcontains $script:RARVER) {
      if ($script:RARVER -gt $LATEST) {
        Write-Warn "Version $(Format-VersionNumber $script:RARVER) is newer than the known latest $(Format-VersionNumber $LATEST)."
      }
      elseif ($script:RARVER -lt $OLDEST) {
        Write-Warn "Version $(Format-VersionNumber $OLDEST) is the earliest known available WinRAR version."
      }
      else {
        Write-Warn "Version $(Format-VersionNumber $script:RARVER) is not a known WinRAR version."
      }

      Confirm-QueryResult -ExpectNegative `
        -Query "Attempt to retrieve unknown version $(Format-VersionNumber $script:RARVER)?" `
        -ResultPositive {
          &$Error_InvalidVersionNumber
          Stop-OcwrOperation -ExitType Error
        } `
        -ResultNegative {
          Write-Info "User confirmed retrieval of unknown version $(Format-VersionNumber $script:RARVER). This version may not exist on the server."
        }
    }
  } else {
    # If not CUSTOM_INSTALLATION
    # REVIEW - DEBUGGING NAME: oneclick-rar
    Set-DefaultArchVersion
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

  Confirm-ScriptNamePosition $config
  # Write-Host "`n--- Confirm-ScriptNamePosition ---"; &$printvariables
  Get-DataFromConfig $config
  # Write-Host "`n--- Get-DataFromConfig ---"; &$printvariables
  Get-SpecialCode
  # Write-Host "`n--- Get-SpecialCode ---"; &$printvariables
  Confirm-SpecialSwitch
  # Write-Host "`n--- Confirm-SpecialSwitch ---"; &$printvariables
  Set-OcwrOperationMode
  # Write-Host "`n--- Set-OcwrOperationMode ---"; &$printvariables
  Confirm-DownloadConfig
  # Write-Host "`n--- Confirm-DownloadConfig ---"; &$printvariables
  &$printvariables
  Pause
}

# --- INSTALLATION

function Invoke-Installer($x, $v) {
  Write-Host "Installing WinRAR $v... " -NoNewLine
  try {
    Start-Process $x "/s" -Wait
    Write-Host "Done."
  }
  catch {
    Stop-OcwrOperation -ScriptBlock {
      New-Toast -ToastTitle "Installation error" -ToastText "The script has run into a problem during installation. Please restart the script."
    }
  }
  finally {
    if (($script:FETCH_WINRAR -or $script:FETCH_WRAR) -and $script:DOWNLOAD_WINRAR -and -not $script:KEEP_DOWNLOAD) {
      Remove-Item $script:WINRAR_EXE
    }
  }
}

function Get-Installer {
  $name = $null
  $file_pattern = $null
  $name_pattern = $null

  if ($script:ARCH -eq 'x32' -and $script:RARVER -lt $LATEST_OLD_WRAR) {
    $script:FETCH_WRAR = $true
    $name = $wrar_name
    $file_pattern = $wrar_file_pattern
    $name_pattern = $wrar_name_pattern
  } else {
    $script:FETCH_WINRAR = $true  # potential issue with this specifically; idk what it is yet
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

function Format-VersionNumber {
  Param($VersionNumber)
  if ($null -eq $VersionNumber) { return $null }
  return "{0:N2}" -f ($VersionNumber / 100)
}

function Get-FormattedWinrarVersion {
  Param($Executable, [Switch]$IntToDouble)

  $version =  if ($IntToDouble) { $Executable }
              elseif ($Executable -match "(?<version>\d{3})") { $matches['version'] }
              else { return $null }
  $version = Format-VersionNumber $version
  return $version
}

function Get-WinRarInstaller {
  Param($HostUri, $HostUriDir)

  $version = Get-FormattedWinrarVersion $script:RARVER -IntToDouble
  if ($script:TAGS) {
    $beta = [regex]::matches($script:TAGS, '\d+')[0].Value
    $lang = $script:TAGS.Trim($beta).ToUpper()
  }

  Write-Host "Connecting to $HostUri... "
  if (Test-Connection "$HostUri" -Count 2 -Quiet) {
    if ($script:FETCH_WRAR) {
      $download_url = "$HostUriDir/wrar$($script:RARVER)$($script:TAGS).exe"
    } else {
      $download_url = "$HostUriDir/winrar-$($script:ARCH)-$($script:RARVER)$($script:TAGS).exe"
    }
    Write-Host -NoNewLine "Verifying download... "
    $responseCode = $(Invoke-WebRequest -Uri $download_url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop).StatusCode
    if ($responseCode -eq 200) {
      Write-Host -NoNewLine "OK.`nDownloading WinRAR $($version)$(if($beta){" Beta $beta"}) ($($script:ARCH))$(if($lang){" ($(Get-LanguageName))"})... "
      Start-BitsTransfer $download_url $pwd\ -ErrorAction SilentlyContinue
    }
    else {
      Write-Error -Message "Download unavailable." -ErrorId "404" -Category NotSpecified 2>$null
    }
  } else {
    New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."; exit
  }
}

function Select-CurrentWinrarInstallation {
  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    Write-Warn "Both 32-bit and 64-bit versions of WinRAR exist on the system. $(Format-Text "Select one." -Foreground Red -Formatting Underline)"
    do {
      $query = Read-Host "Enter `"1`" for 32-bit and `"2`" for 64-bit"
      if ($query -eq 1) { $script:WINRAR_INSTALLED_LOCATION = $loc32; break }
      elseif ($query -eq 2) { $script:WINRAR_INSTALLED_LOCATION = $loc64; break }
    } while ($true)
  }
  Write-Info "Selected WinRAR installation: $(Format-Text $($script:WINRAR_INSTALLED_LOCATION) -Foreground White -Formatting Underline)."
}

function Confirm-CurrentWinrarInstallation {
  $civ = $(&$script:WINRAR_INSTALLED_LOCATION\rar.exe "-iver") # current installed version
  if ("$civ" -match $(Format-VersionNumber $script:RARVER)) {
    Write-Info "This version of WinRAR is already installed: $(Format-Text $(Format-VersionNumber $script:RARVER) -Foreground White -Formatting Underline)"
    Confirm-QueryResult -ExpectNegative `
      -Query "Continue with installation?" `
      -ResultPositive { Write-Info "User confirmed re-installation of WinRAR verison $(Format-VersionNumber $script:RARVER)." } `
      -ResultNegative { Stop-OcwrOperation }
  }
}

# --- BEGIN

# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations
# Grab the name of the script file and process any
# customization data set by the user
if ($CMD_NAME -ne $script_name) { Confirm-ConfigData }
else { Set-DefaultArchVersion }

if ($script:WINRAR_IS_INSTALLED) {
  Select-CurrentWinrarInstallation
  Confirm-CurrentWinrarInstallation
}

function Invoke-OwcrInstallation {
  if (-not $script:LICENSE_ONLY) {
    # This ensures that the script does not unnecessarily
    # download a new installer if one is available in the
    # current directory
    $script:WINRAR_EXE = (Get-Installer)

    # if there are no installers, proceed to download one
    if ($null -eq $script:WINRAR_EXE) {
      $script:DOWNLOAD_WINRAR = $true

      $Error.Clear()
      $local:retrycount = 0
      $local:version = (Get-FormattedWinrarVersion $script:RARVER -IntToDouble)

      Get-WinRarInstaller -HostUri $server1_host -HostUriDir $server1
      foreach ($wdir in $server2) {
        if ($Error) {
          $Error.Clear()
          $local:retrycount++
          Write-Host -NoNewLine "`nFailed. Retrying... $local:retrycount`n"
          Get-WinRarInstaller -HostUri $server2_host -HostUriDir $wdir
        }
      }
      if ($Error) {
        if ($script:CUSTOM_INSTALLATION) {
          New-Toast -ToastTitle "Unable to fetch download" `
                    -ToastText  "WinRAR $($local:version) ($script:ARCH) may not exist on the server." `
                    -ToastText2 "Check the version number and try again."; exit
        } else {
          New-Toast -ToastTitle "Unable to fetch download" `
                    -ToastText  "Are you still connected to the internet?" `
                    -ToastText2 "Please check your internet connection."; exit
        }
      }
      if ($script:DOWNLOAD_ONLY) {
        New-Toast -ToastTitle "Download Complete" `
                  -ToastText  "WinRAR $($local:version) ($script:ARCH) was successfully downloaded." `
                  -ToastText2 "Run this script again if you ever need to install it."; exit
      }
      $script:WINRAR_EXE = (Get-Installer) # get the new installer
      Write-Host "Done."
    } else {
      Write-Info "Found executable versioned at $(Format-Text (Get-FormattedWinrarVersion $script:WINRAR_EXE) -Foreground White -Formatting Underline)"
    }
    if ($script:DOWNLOAD_ONLY) {
      New-Toast -ToastTitle "Download Aborted" `
                -ToastText  "An installer for WinRAR $(Get-FormattedWinrarVersion $script:WINRAR_EXE) ($script:ARCH) already exists." `
                -ToastText2 "Check the requested download version and try again."; exit
    }

    Invoke-Installer $script:WINRAR_EXE (Get-FormattedWinrarVersion $script:WINRAR_EXE)
  }
}

Invoke-OwcrInstallation

# --- LICENSING

function Invoke-OcwrLicensing {
  if (-not $script:SKIP_LICENSING) {
    # $rarloc = (Get-InstalledWinrarLocations)
    switch ($script:ARCH) {
      'x64' {
        if (Test-Path $winrar64 -PathType Leaf) {
          $keygen = $keygen64
          $rarreg = $rarreg64
        }
        else {
          Write-Info "WinRAR is not installed."
          Confirm-QueryResult -ExpectNegative `
            -Query "Do you want to install WinRAR version $(Format-VersionNumber $script:RARVER)?" `
            -ResultPositive {
              $script:LICENSE_ONLY = $false
              Invoke-OwcrInstallation
            } `
            -ResultNegative {
              Stop-OcwrOperation -ExitType Error -ScriptBlock {
                New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Run this script to install WinRAR before licensing."
              }
            }
        }
        break
      }
      'x32' {
        if (Test-Path $winrar32 -PathType Leaf) {
          $keygen = $keygen32
          $rarreg = $rarreg32
        }
        else {
          Write-Info "WinRAR is not installed."
          Confirm-QueryResult -ExpectNegative `
            -Query "Do you want to install WinRAR version $(Format-VersionNumber $script:RARVER)?" `
            -ResultPositive {
              $script:LICENSE_ONLY = $false
              Invoke-OwcrInstallation
            } `
            -ResultNegative {
              Stop-OcwrOperation -ExitType Error -ScriptBlock {
                New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Run this script to install WinRAR before licensing."
              }
            }
        }
        break
      }
      default {
        Stop-OcwrOperation -ExitType Error -ScriptBlock {
          New-Toast -ToastTitle "There was a problem licensing WinRAR" -ToastText "Please verify the script config and try again."; exit
        }
        break
      }
    }

    # install WinRAR license
    if (-not(Test-Path $rarreg -PathType Leaf) -or $script:OVERWRITE_LICENSE) {
      if ($script:CUSTOM_LICENSE) {
        if (Test-Path $keygen -PathType Leaf) {
          &$keygen "$($script:licensee)" "$($script:license_type)" | Out-File -Encoding utf8 $rarreg
        }
        else {
          New-Toast -ActionButtonUrl "$link_howtouse" `
                    -ToastTitle "Missing `"bin`" folder" `
                    -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."; exit
        }
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
      Write-Info "A WinRAR license already exists."
      Confirm-QueryResult -ExpectNegative `
        -Query "Do you want to overwrite the current license?" `
        -ResultPositive {
          $script:OVERWRITE_LICENSE = $true
          Invoke-OcwrLicensing
        } `
        -ResultNegative {
          $Text_viewDocumentationForLicensing = "View the documentation on how to use the override switch to install a new license."
          $Text_LicenseAlreadyExists = "Notice: A WinRAR license already exists."
          if ($script:LICENSE_ONLY) {
            New-Toast -LongerDuration `
                      -ToastTitle "Unable to license WinRAR" -ActionButtonUrl $link_overwriting `
                      -ToastText  $Text_LicenseAlreadyExists `
                      -ToastText2 $Text_viewDocumentationForLicensing
          } else {
            New-Toast -LongerDuration `
                      -ToastTitle "WinRAR installed successfully but.." -ActionButtonUrl $link_overwriting `
                      -ToastText  $Text_LicenseAlreadyExists `
                      -ToastText2 $Text_viewDocumentationForLicensing
          }
          Stop-OcwrOperation -ExitType Warning
        }
    }
  }
}

Invoke-OcwrLicensing

# --- SUCCESSFUL EXIT TOAST MESSAGES

<#
if ($script:SKIP_LICENSING) {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
} elseif ($script:LICENSE_ONLY) {
  if ($script:CUSTOM_LICENSE) {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Licensed to `"$($script:licensee)`"" `
              -ToastText2 "Freedom throughout the universe!"; exit
  } else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR licensed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
  }
} elseif ($script:CUSTOM_LICENSE) {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Licensed to `"$($script:licensee)`"" `
              -ToastText2 "Freedom throughout the universe!"; exit
} else {
    New-Toast -Url $link_freedom_universe_yt `
              -ToastTitle "WinRAR installed and licensed successfully" `
              -ToastText  "Freedom throughout the universe!"; exit
}
#>

$exit_Url = $link_freedom_universe_yt
$exit_ToastTitle = "WinRAR installed successfully"
$exit_ToastText = "Freedom throughout the universe!"
$exit_ToastText2 = $null

$exit_ToastTitle = "WinRAR$(if(-not $script:LICENSE_ONLY){" installed "})$(if(-not ($script:SKIP_LICENSING -or $script:LICENSE_ONLY)){"and"})$(if($script:LICENSE_ONLY -or $script:CUSTOM_LICENSE){" licensed "})successfully"
if ($script:CUSTOM_LICENSE) { $exit_ToastText2 = $exit_ToastText; $exit_ToastText = "Licensed to `"$($script:licensee)`""}
New-Toast -Url $exit_Url -ToastTitle $exit_ToastTitle -ToastText  $exit_ToastText -ToastText2 $exit_ToastText2; exit
