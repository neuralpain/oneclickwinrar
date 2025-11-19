[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region Variables
$script_name = "installrar"

$winrar_name = "winrar"
$winrar_name_pattern = "^winrar-x"
$winrar_file_pattern = "winrar-x\d{2}-\d{3}\w*\.exe"

# old WinRAR name pattern
$wrar_name = "wrar"
$wrar_name_pattern = "^wrar"
$wrar_file_pattern = "wrar\d{3}\w*\.exe"

$loc32 = "${env:ProgramFiles(x86)}\WinRAR"
$loc64 = "$env:ProgramFiles\WinRAR"
$loc96 = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$server1_host = "www.rarlab.com"
$server1 = "https://$server1_host/rar"
$server2_host = "www.win-rar.com"
$server2 = @("https://$server2_host/fileadmin/winrar-versions", "https://$server2_host/fileadmin/winrar-versions/winrar")

#####KNOWN_VERSION_LIST#####

#####KNOWN_LANGUAGE_LIST#####

$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_endof32bitsupport = "https://www.win-rar.com/singlenewsview.html?&L=0&tx_ttnews%5Btt_news%5D=266&cHash=44c8cdb0ff6581307702dfe4892a3fb5"

$OLDEST = 290
$script:LATEST = $script:KNOWN_VERSIONS[0]
$FIRST_64BIT = 390
$LATEST_32BIT = 701
$LATEST_OLD_WRAR = 611

#####STATUS_CODES#####
#endregion

#region Switch Configs
$script:WINRAR_EXE = $null
$script:FETCH_WINRAR = $false                     # Download standard WinRAR
$script:FETCH_WRAR = $false                       # Download old 32-bit WinRAR naming scheme
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:CUSTOM_INSTALLATION = $false
$script:DOWNLOAD_WINRAR = $false

$script:ARCH = $null                              # Download architecture
$script:RARVER = $null                            # WinRAR version
$script:TAGS = $null                              # Other download types, i.e. beta, language
#endregion

#region Utility
#####UTILITIES#####
#####CONFIRM_QUERY#####
#####VERSION_FORMAT#####
#endregion

#region Title
#####TITLE_HEADER#####
#endregion

#region Messages
#####MESSAGES#####
#endregion

#region Location and Defaults
#####LOCATIONS#####
#####DEFAULT_ARCH_VERSION#####
#endregion

#region WinRAR Updates
#####UPDATES#####
#endregion

#region Data Processing
#####LANG_PROCESSING#####
#####RESOLVE_DOWNLOAD_CONFIG#####

function Resolve-ScriptConfiguration {
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

  Resolve-DownloadConfiguration
}
#endregion



#region Installation
#####INSTALLATION#####
#endregion

#region Begin Execution
# Begin by retrieving any current installations of WinRAR
Get-InstalledWinrarLocations

# Grab the name of the script file and process any
# configuration data set by the user
if ($CMD_NAME -ne $script_name) {
  $script:CUSTOM_INSTALLATION = $true
  Resolve-ScriptConfiguration
} else {
  Update-WinrarLatestVersion
  Set-DefaultArchVersion
}

if ($script:WINRAR_IS_INSTALLED) {
  Set-InstallationTargetDirectory
  Confirm-InstallationOverwrite
}

Start-WinrarInstallation

New-Toast -Url "https://ko-fi.com/neuralpain" -ToastTitle "WinRAR installed successfully" -ToastText2 "Thanks for using oneclickwinrar!"
Stop-OcwrOperation -ExitType Complete
#endregion
