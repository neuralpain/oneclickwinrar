#region Variables
$script_name = "unlicenserar"
$script_name_uninstall = "un-licenserar"

$rarloc = ""
$loc32 = "${env:ProgramFiles(x86)}\WinRAR"
$loc64 = "$env:ProgramFiles\WinRAR"
$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"
#endregion

#region Switch Configs
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null
$UNINSTALL = $false
#endregion

#region Utility
#####UTILITIES#####
#endregion

#region Title
#####TITLE_HEADER#####
#endregion

#region Messages
#####MESSAGES#####
#endregion

#region Location
#####LOCATIONS#####
#endregion

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

#region Begin Execution
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
  #####UNINSTALLATION#####
}

#####UNLICENSING#####

#endregion
