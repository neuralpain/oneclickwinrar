<# :# DO NOT REMOVE THIS LINE

:: licenserar.cmd
:: Last updated @ v0.12.0.712
:: Copyright (c) 2023, neuralpain
:: License WinRAR

@echo off
mode 78,40
title licenserar (v0.12.2.713)
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

# --- VARIABLES

$script_name           = "licenserar"
$script_name_overwrite = "license-rar"

$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$loc96    = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$rarreg   = $null
$rarkey   = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$loc64\rarreg.key"
$rarreg32 = "$loc32\rarreg.key"

$keygen      = $null
$keygenUrl   = $null
$keygen64    = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32    = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygenUrl32 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x86.exe"
$keygenUrl64 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x64.exe"

# --- SWITCH / CONFIGS ---
$script:WINRAR_IS_INSTALLED       = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:licensee          = $null
$script:license_type      = $null
$script:CUSTOM_LICENSE    = $false
$script:OVERWRITE_LICENSE = $false
# --- END SWITCH / CONFIGS ---

# --- MESSAGES

$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_howtouse      = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_namepattern   = "https://github.com/neuralpain/oneclickwinrar#naming-patterns"
$link_overwriting   = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"

$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_InvalidLicenseData = {
  New-Toast -ActionButtonUrl $link_namepattern -ToastTitle "Licensing error" -ToastText "Custom lincense data is invalid. Check the license data and try again."
  Stop-OcwrOperation -ExitType Error -Message
}

$Error_LicenseExists = {
  New-Toast -LongerDuration -ToastTitle "Unable to license WinRAR" -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_BinFolderMissing = {
  New-Toast -ActionButtonUrl $link_howtouse -ToastTitle "Missing `"bin`" folder" -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."
  Stop-OcwrOperation -ExitType Warning -Message "Missing `"bin`" folder"
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}

# --- FUNCTIONS

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

function Invoke-OcwrLicensing {
  <#
    .DESCRIPTION
      Licensing instructions to be executed.
  #>

  if ($script:WINRAR_INSTALLED_LOCATION -eq $loc96) {
    Select-WinrarInstallation # confirm 32/64-bit
  }

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
    Write-Warn "A WinRAR license already exists"
    Confirm-QueryResult -ExpectNegative `
      -Query "Do you want to overwrite the current license?" `
      -ResultPositive {
        $script:OVERWRITE_LICENSE = $true
        Invoke-OcwrLicensing
      } `
      -ResultNegative { &$Error_LicenseExists }
  }
}

# --- BEGIN

Write-Title

Get-InstalledWinrarLocations

if (-not $script:WINRAR_IS_INSTALLED) {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Install WinRAR before licensing."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR is not installed."
}

# Check for custom license data
if ($CMD_NAME -ne $script_name) {
  $config = [regex]::matches($CMD_NAME, '[^_]+')
  if ($config.Count -gt 3) { &$Error_TooManyArgs }
  elseif ($config.Count -eq 2) {
    if ($config[1].Value -eq $script_name) {
      $script:CUSTOM_LICENSE = $true
      $script:licensee = $config[0].Value
      $script:license_type = "Single User License"
    }
    else {
      &$Error_UnknownScript
    }
  }
  elseif ($config.Count -eq 1) {
    # User only wants to overwrite the existing license
    if ($config[0].Value -eq $script_name_overwrite) {
      $script:OVERWRITE_LICENSE = $true
    }
    else { &$Error_UnknownScript }
  }
  else {
    # `$config[2]` is the script name
    $script:CUSTOM_LICENSE = $true
    $script:licensee = $config[0].Value
    $script:license_type = $config[1].Value

    if ($config[2].Value -eq $script_name_overwrite) {
      # Custom license, script name is valid, but user
      # wants to overwrite an existing license
      $script:OVERWRITE_LICENSE = $true
    }
    elseif ($config[2].Value -ne $script_name) {
      &$Error_UnknownScript
    }
  }
  # Verify custom license data --- this is a sanity check
  if ($script:licensee.Length -eq 0 -or $script:license_type.Length -eq 0) {
    &$Error_InvalidLicenseData
  }
}

Invoke-OcwrLicensing

if ($script:CUSTOM_LICENSE) {
  Write-Host "`nLicensee:`t$($script:licensee)`nLicense:`t$($script:license_type)`n"
  New-Toast -Url "https://ko-fi.com/neuralpain" `
            -ToastTitle "WinRAR licensed successfully" `
            -ToastText "Licensee: $($script:licensee)`nLicense: $($script:license_type)" `
            -ToastText2 "Thanks for using oneclickwinrar!"
}
else {
  New-Toast -Url "https://ko-fi.com/neuralpain" `
            -ToastTitle "WinRAR licensed successfully" `
            -ToastText "Thanks for using oneclickwinrar!"
}

Stop-OcwrOperation -ExitType Complete
