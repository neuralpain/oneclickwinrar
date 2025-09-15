<# :# DO NOT REMOVE THIS LINE

:: installrar.cmd
:: Last updated @ v0.13.1.713
:: Copyright (c) 2023, neuralpain
:: Install WinRAR

@echo off
mode 78,40
title installrar (v0.13.1.713)

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

#region Variables
$script_name = "installrar"

$winrar_name         = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# old WinRAR name pattern
$wrar_name           = "wrar"
$wrar_name_pattern   = "^wrar"
$wrar_file_pattern   = "wrar\d{3}\w*\.exe"

$loc32    = "${env:ProgramFiles(x86)}\WinRAR"
$loc64    = "$env:ProgramFiles\WinRAR"
$loc96    = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$server1_host    = "www.rarlab.com"
$server1         = "https://$server1_host/rar"
$server2_host    = "www.win-rar.com"
$server2         = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

$script:KNOWN_VERSIONS  = @(713, 712, 711, 710, 701, 700, 624, 623, 622, 621, 620, 611, 610, 602, 601, 600, 591, 590, 580, 571, 570, 561, 560, 550, 540, 531, 530, 521, 520, 511, 510, 501, 500, 420, 411, 410, 401, 400, 393, 390, 380, 371, 370, 360, 350, 340, 330, 320, 310, 300, 290)
$LANG_CODE_LIST  = @("ar","al","am","az","by","ba","bg","bur","ca","sc","tc","cro","cz","dk","nl","en","eu","est","fi","fr","gl","d","el","he","hu","id","it","jp","kr","lt","mk","mn","no","prs","pl","pt","br","ro","ru","srbcyr","srblat","sk","slv","es","ln","esco","sw","th","tr","uk","uz","va","vn")
$LANG_NAME_LIST  = @("Arabic","Albanian","Armenian","Azerbaijani","Belarusian","Bosnian","Bulgarian","Burmese (Myanmar)","Catalan","Chinese Simplified","Chinese Traditional","Croatian","Czech","Danish","Dutch","English","Euskera","Estonian","Finnish","French","Galician","German","Greek","Hebrew","Hungarian","Indonesian","Italian","Japanese","Korean","Lithuanian","Macedonian","Mongolian","Norwegian","Persian","Polish","Portuguese","Portuguese Brazilian","Romanian","Russian","Serbian Cyrillic","Serbian Latin","Slovak","Slovenian","Spanish","Spanish (Latin American)","Spanish Colombian","Swedish","Thai","Turkish","Ukrainian","Uzbek","Valencian","Vietnamese")

$default_lang_code = 'en'
$default_lang_name = 'English'

$link_configuration     = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_endof32bitsupport = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$OLDEST          = 290
$script:LATEST   = $script:KNOWN_VERSIONS[0]
$FIRST_64BIT     = 390
$LATEST_32BIT    = 701
$LATEST_OLD_WRAR = 611
#endregion

#region Switch Configs
$script:WINRAR_EXE   = $null
$script:FETCH_WINRAR = $false                     # Download standard WinRAR
$script:FETCH_WRAR   = $false                     # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:CUSTOM_INSTALLATION = $false
$script:DOWNLOAD_WINRAR     = $false

$script:ARCH   = $null                            # Download architecture
$script:RARVER = $null                            # WinRAR version
$script:TAGS   = $null                            # Other download types, i.e. beta, language
#endregion

#region Utility
function Write-Info{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "INFO: $Message" -ForegroundColor DarkCyan}
function Write-Warn{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "WARN: $Message" -ForegroundColor Yellow}
function Write-Err{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "ERROR: $Message" -ForegroundColor Red}
# Format-Text.ps1 <https://gist.github.com/neuralpain/7d0917553a55db4eff482b2eb3fcb9a3>
function Format-Text{[CmdletBinding()]Param([Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true)][String]$Text,[Parameter(Mandatory=$false)][ValidateSet(8,24)][Int]$BitDepth,[Parameter(Mandatory=$false)][ValidateCount(1,3)][String[]]$Foreground,[Parameter(Mandatory=$false)][ValidateCount(1,3)][String[]]$Background,[Parameter(Mandatory=$false)][String[]]$Formatting);$Esc=[char]27;$Reset="${Esc}[0m";switch($BitDepth){8{if($null -eq $Foreground -or $Foreground -lt 0){$Foreground=0}if($null -eq $Background -or $Background -lt 0){$Background=0}if($Foreground -gt 255){$Foreground=255}if($Background -gt 255){$Background=255}$Foreground="${Esc}[38;5;${Foreground}m";$Background="${Esc}[48;5;${Background}m";break}24{foreach($color in $Foreground){if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_foreground+=";${color}"}foreach($color in $Background){if($null -eq $color -or $color -lt 0){$color=0}if($color -gt 255){$color=255}$_background+=";${color}"}$Foreground="${Esc}[38;2${_foreground}m";$Background="${Esc}[48;2${_background}m";break;}default{switch($Foreground){'Black'{$Foreground="${Esc}[30m"}'DarkRed'{$Foreground="${Esc}[31m"}'DarkGreen'{$Foreground="${Esc}[32m"}'DarkYellow'{$Foreground="${Esc}[33m"}'DarkBlue'{$Foreground="${Esc}[34m"}'DarkMagenta'{$Foreground="${Esc}[35m"}'DarkCyan'{$Foreground="${Esc}[36m"}'Gray'{$Foreground="${Esc}[37m"}'DarkGray'{$Foreground="${Esc}[90m"}'Red'{$Foreground="${Esc}[91m"}'Green'{$Foreground="${Esc}[92m"}'Yellow'{$Foreground="${Esc}[93m"}'Blue'{$Foreground="${Esc}[94m"}'Magenta'{$Foreground="${Esc}[95m"}'Cyan'{$Foreground="${Esc}[96m"}'White'{$Foreground="${Esc}[97m" }default{$Foreground=""}}switch($Background){'Black'{$Background="${Esc}[40m"}'DarkRed'{$Background="${Esc}[41m"}'DarkGreen'{$Background="${Esc}[42m"}'DarkYellow'{$Background="${Esc}[43m"}'DarkBlue'{$Background="${Esc}[44m"}'DarkMagenta'{$Background="${Esc}[45m"}'DarkCyan'{$Background="${Esc}[46m"}'Gray'{$Background="${Esc}[47m"}'DarkGray'{$Background="${Esc}[100m"}'Red'{Background="${Esc}[101m"}'Green'{$Background="${Esc}[102m"}'Yellow'{$Background="${Esc}[103m"}'Blue'{$Background="${Esc}[104m"}'Magenta'{$Background="${Esc}[105m"}'Cyan'{$Background="${Esc}[106m"}'White'{$Background="${Esc}[107m"}default{$Background=""}}break}};if($Formatting.Length -eq 0){$Format=""}else{$i=0;$Format="${Esc}[";foreach($type in $Formatting){switch($type){'Bold'{$Format+="1"}'Dim'{$Format+="2"}'Underline'{$Format+="4"}'Blink'{$Format+="5"}'Reverse'{$Format+="7"}'Hidden'{$Format+="8"}default{$Format+=""}}$i++;if($i -lt ($Formatting.Length)){$Format+=";"}else{$Format+="m";break}}};$OutString="${Foreground}${Background}${Format}${Text}${Reset}";Write-Output $OutString;}
# New-ToastNotification.ps1 <https://gist.github.com/neuralpain/283a2de1e7078c95e0c97a4fb6cc0e08>
function New-Toast{[CmdletBinding()]Param([String]$AppId="oneclickwinrar",[String]$Url,[String]$ToastTitle,[String]$ToastText,[String]$ToastText2,[string]$Attribution,[String]$ActionButtonUrl,[String]$ActionButtonText="Open documentation",[switch]$KeepAlive,[switch]$LongerDuration);[Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime]|Out-Null;$Template=[Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText04);$RawXml=[xml] $Template.GetXml();($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle))|Out-Null;($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText))|Out-Null;($RawXml.toast.visual.binding.text|Where-Object{$_.id -eq "3"}).AppendChild($RawXml.CreateTextNode($ToastText2))|Out-Null;$XmlDocument=New-Object Windows.Data.Xml.Dom.XmlDocument;$XmlDocument.LoadXml($RawXml.OuterXml);if($Url){$XmlDocument.DocumentElement.SetAttribute("activationType","protocol");$XmlDocument.DocumentElement.SetAttribute("launch",$Url)}if($Attribution){$attrElement=$XmlDocument.CreateElement("text");$attrElement.SetAttribute("placement","attribution");$attrElement.InnerText=$Attribution;$bindingElement=$XmlDocument.SelectSingleNode('//toast/visual/binding');$bindingElement.AppendChild($attrElement)|Out-Null}if($ActionButtonUrl){$actionsElement=$XmlDocument.CreateElement("actions");$actionElement=$XmlDocument.CreateElement("action");$actionElement.SetAttribute("content",$ActionButtonText);$actionElement.SetAttribute("activationType","protocol");$actionElement.SetAttribute("arguments",$ActionButtonUrl);$actionsElement.AppendChild($actionElement)|Out-Null;$XmlDocument.DocumentElement.AppendChild($actionsElement)|Out-Null}if($KeepAlive){$XmlDocument.DocumentElement.SetAttribute("scenario","incomingCall")}elseif($LongerDuration){$XmlDocument.DocumentElement.SetAttribute("duration","long")};$Toast=[Windows.UI.Notifications.ToastNotification]::new($XmlDocument);$Toast.Tag="PowerShell";$Toast.Group="PowerShell";if(-not($KeepAlive -or $LongerDuration)){$Toast.ExpirationTime=[DateTimeOffset]::Now.AddMinutes(1)};$Notifier=[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId);$Notifier.Show($Toast)}

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
}; Write-Title

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

function Format-VersionNumber {
  <#
    .DESCRIPTION
      Format version numbers as x.xx

    .EXAMPLE
      Format-VersionNumber -Version 710
  #>
  Param($VersionNumber)
  if ($null -eq $VersionNumber) { return $null }
  return "{0:N2}" -f ($VersionNumber / 100)
}

function Format-VersionNumberFromExecutable {
  <#
    .DESCRIPTION
      Retrieve the WinRAR version form the executable name and format it.

    .EXAMPLE
      Format-VersionNumberFromExecutable -Executable winrar-x64-712.exe
  #>
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    $Executable
  )

  $version = if ($Executable -match "(?<version>\d{3})") { $matches['version'] }
             else { return $null }
  $version = Format-VersionNumber $version
  return $version
}
#endregion

#region Messages
$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_configuration" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_NoInternetConnection = {
  New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."
  Stop-OcwrOperation -ExitType Error -Message "Internet connection lost or unavailable."
}

$Error_UnableToConnectToDownload = {
  New-Toast -ToastTitle "Unable to make a connection" -ToastText "Please check your internet or firewall rules."
  Stop-OcwrOperation -ExitType Error -Message "Unable to make a connection."
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}

$Error_No32bitSupport = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "No 32-bit support for this version of WinRAR."
}

$Error_InvalidVersionNumber = {
  New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number provided is greater than the latest version available."
  Stop-OcwrOperation -ExitType Error -Message "Invalid version number."
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
    Write-Info "Using default `"x64`" architecture"
    $script:ARCH = "x64"
  }
  if ($null -eq $script:RARVER) {
    Write-Info "Using default version $($script:LATEST)"
    $script:RARVER = $script:LATEST
  }
  if ($null -eq $script:TAGS) {
    Write-Info "WinRAR language set to $(Format-Text "English" -Foreground White -Formatting Underline)"
    $script:RARVER = $script:LATEST
  }
}
#endregion

#region WinRAR Updates
function Test-WinrarVersionAvailability {
  <#
    .SYNOPSIS
      Checks a list of URLs to verify if they likely point to valid
      download.

    .DESCRIPTION
      This script takes an array of URLs as input. For each URL, it performs an
      HTTP HEAD request to retrieve the headers. It then analyzes the StatusCode
      header to determine if the URL is accessible to download files.

    .PARAMETER URLs
      An array of strings, where each string is a URL to check.

    .EXAMPLE
      Test-WinrarVersionAvailability -URLs @(
          "https://www.rarlab.com/rar/winrar-x64-{version}.exe",
          "https://www.win-rar.com/fileadmin/winrar-versions/winrar-x64-{version}.exe"
          "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-{version}.exe"
        )

    .OUTPUTS
      System.Boolean. The function returns $true if at least one URL returns a
      200 OK status code. Otherwise, it implicitly returns $null.
  #>
  Param([Parameter(Mandatory = $true)][string[]]$URLs)

  foreach ($url in $URLs) {
    try {
      $statusCode = $(Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop).StatusCode
      if ($statusCode -eq 200) {
        # if at least one of the URLs connect, then it's good.
        return $true # --- sentinel
      }
    }
    catch [System.Net.WebException] {
      # Will return 404 if the downloads are not available.
    }
    catch {
      # Generally, we don't care about the errors here. This function is only for
      # testing availability. If it can't connect in any way, it's invalid.
    }
  }
}

function Find-WinrarUpdates {
  <#
    .SYNOPSIS
      Checks for new versions of WinRAR available for download.

    .DESCRIPTION
      This function takes an array of known versions `$kvList` and splits the latest
      known version (at index `0`) into the semantic pattern variables `$patch`,
      `$minor` and `$major`. The function then checks for the availability of
      the next 10 iterative versions. If a version is found, it is added to a
      `$newVersions` list that is then sorted, compared and returned if
      successful. If not, it returns $null.

    .PARAMETER kvList
      An array of strings containing the known version numbers to check for
      updates against.

    .OUTPUTS
      System.String[]. An array of strings containing the new version numbers
      found, sorted from newest to oldest. If no new versions are found, it
      returns $null.
  #>
  Param([string[]]$kvList)

  $patch = [int]($kvList[0] % 10)
  $minor = [int](($kvList[0] % 100) / 10)
  $major = [int](($kvList[0] % 1000) / 100)

  $newVersions = @()

  Write-Info "Checking for WinRAR updates..."

  for ($j = $minor; $j -le $minor+1; $j++) {
    if ($j -gt $minor) { $patch = 0 }
    for ($k = $patch; $k -lt 10; $k++) {
      $testVersion = $major*100 + $j*10 + $k
      if ((Test-WinrarVersionAvailability -URLs @("$server1/winrar-x64-$($testVersion).exe","$($server2[0])/winrar-x64-$($testVersion).exe","$($server2[1])/winrar-x64-$($testVersion).exe"))) {
        $newVersions += $testVersion
      }
    }
  }

  if ($null -ne $newVersions) {
    $newVersions = $($newVersions | Sort-Object -Descending)
    $newVersion = $newVersions[0]
    if ($newVersion -gt $kvList[0]) {
      Write-Info "New version found. Updating dedault version to $(Format-Text $newVersion -Foreground White)"
      return $newVersions
    } else {
      Write-Info "No WinRAR updates found."
      return $null
    }
  }
}

function Get-WinrarLatestVersion {
  <#
    .SYNOPSIS
      Checks for latest version of WinRAR.

    .DESCRIPTION
      This function scrapes the www.rarlab.com website for the latest version of
      WinRAR listed in the "What's New" page context. If unsuccessful, the
      functiosn returns `0`.

    .OUTPUTS
      System.Int32. The latest version as an integer. If a new version has not
      been found, the function returns `0`.
  #>
  # Public changelog
  $url = "https://www.rarlab.com/rarnew.htm"
  # User agent to avoid being blocked
  $userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

  Write-Info "Checking latest WinRAR version..."

  try {
    $htmlContent = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing | Select-Object -ExpandProperty Content
    $_matches = [regex]::Matches($htmlContent, '(?i)Version\s+(\d+\.\d+)')

    if (-not $_matches.Count) {
      Write-Err "Unable to find latest version. The page content might have changed or the request was blocked."
      return 0
    }

    $versions = $_matches.Groups[1].Captures | Select-Object -Unique | ForEach-Object {
      try {
        [version]$_.Value
      }
      catch {
        # Skip any invalid version strings
      }
    }

    if ($versions.Count -eq 0) {
      Write-Err "No valid version numbers were found."
      return 0
    }

    $latestVersion = $versions | Sort-Object -Descending | Select-Object -First 1
    $latestVersion = [int](($latestVersion.Major * 100) + $latestVersion.Minor)
    return $latestVersion
  }
  catch {
    Write-Error "An error occurred during the web request: $($_.Exception.Message)"
  }
}

function Add-ToKnownVersionsList {
  Param([string]$Version)
  $script:KNOWN_VERSIONS += $Version
  $script:KNOWN_VERSIONS = $script:KNOWN_VERSIONS | Sort-Object -Descending
}

function Update-KnownVersionsList {
  $local:vl = Find-WinrarUpdates -kvList $script:KNOWN_VERSIONS
  if ($null -ne $local:vl) {
    Add-ToKnownVersionsList -Version $local:vl
  }
}

function Update-WinrarLatestVersion {
  if (Test-Connection $server1_host -Count 2 -Quiet) {
    $local:v = (Get-WinrarLatestVersion)

    if ($local:v -eq 0) {
      Update-KnownVersionsList
    } else {
      if ($local:v -eq $script:LATEST) {
        Write-Info "Default version is the latest version."
      } else {
        Add-ToKnownVersionsList -Version $local:v
        Write-Info "Updated default version to latest version."
      }
    }

    $script:LATEST = $script:KNOWN_VERSIONS[0]
  } else { &$Error_NoInternetConnection }
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
      Write-Info "Using latest WinRAR version $(Format-VersionNumber $script:LATEST)"
      $script:RARVER = $script:LATEST
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
      Write-Info "Using latest 64-bit version $(Format-VersionNumber $script:LATEST)"
      $script:RARVER = $script:LATEST
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
  if ($script:RARVER -match '^\d{3,}$' -and $script:KNOWN_VERSIONS -notcontains $script:RARVER) {
    if ($script:RARVER -gt $script:LATEST) {
      Write-Warn "Version $(Format-VersionNumber $script:RARVER) is newer than the known latest $(Format-VersionNumber $script:LATEST)"
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
    .DESCRIPTION
      Parse the script name and determine the type of operation.
  #>

  $config = [regex]::matches($CMD_NAME, '[^_]+')

  if ($config.Count -gt 4) { &$Error_TooManyArgs }
  if ($config[0].Value -ne $script_name) { &$Error_UnknownScript }

  $script:ARCH = $config[1].Value
  $script:RARVER = $config[2].Value
  $script:TAGS = $config[3].Value

  if (($null -or 'x64') -eq $script:ARCH) {
    Update-WinrarLatestVersion
  }

  Confirm-DownloadConfig
}
#endregion

#region Installation
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
        Write-Info "Confirmed re-installation of WinRAR version $(Format-VersionNumber $script:RARVER)"
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

function Invoke-OwcrInstallation {
  <#
    .DESCRIPTION
      Installation instructions to be executed (if not disabled).
  #>

  # This ensures that the script does not unnecessarily
  # download a new installer if one is available in the
  # current directory
  $script:WINRAR_EXE = (Get-LocalWinrarInstaller)

  # if there are no installers, proceed to download one
  if ($null -eq $script:WINRAR_EXE) {
    $script:DOWNLOAD_WINRAR = $true

    $Error.Clear()
    $local:retrycount = 0
    $local:version = (Format-VersionNumber $script:RARVER)

    Get-WinrarInstaller -HostUri $server1_host -HostUriDir $server1
    foreach ($wdir in $server2) {
      if ($Error) {
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
    $script:WINRAR_EXE = (Get-LocalWinrarInstaller) # get the new installer
  } else {
    Write-Info "Found executable versioned at $(Format-Text (Format-VersionNumberFromExecutable $script:WINRAR_EXE) -Foreground White -Formatting Underline)"
  }

  Invoke-Installer $script:WINRAR_EXE (Format-VersionNumberFromExecutable $script:WINRAR_EXE)
}
#endregion

#region Begin Execution
# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations

# Grab the name of the script file and process any
# configuration data set by the user
if ($CMD_NAME -ne $script_name) {
  $script:CUSTOM_INSTALLATION = $true
  Confirm-ConfigData
} else {
  Update-WinrarLatestVersion
  Set-DefaultArchVersion
}

if ($script:WINRAR_IS_INSTALLED) {
  Select-CurrentWinrarInstallation
  Confirm-CurrentWinrarInstallation
}

Invoke-OwcrInstallation

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"
Stop-OcwrOperation -ExitType Complete
#endregion
