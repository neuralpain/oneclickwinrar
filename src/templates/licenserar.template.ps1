[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region Variables
$script_name = "licenserar"
$script_name_overwrite = "license-rar"

$loc32 = "${env:ProgramFiles(x86)}\WinRAR"
$loc64 = "$env:ProgramFiles\WinRAR"
$loc96 = "x96"

$winrar64 = "$loc64\WinRAR.exe"
$winrar32 = "$loc32\WinRAR.exe"

$rarreg = $null
$rarkey = "RAR registration data`r`nEveryone`r`nGeneral Public License`r`nUID=119fdd47b4dbe9a41555`r`n6412212250155514920287d3b1cc8d9e41dfd22b78aaace2ba4386`r`n9152c1ac6639addbb73c60800b745269020dd21becbc46390d7cee`r`ncce48183d6d73d5e42e4605ab530f6edf8629596821ca042db83dd`r`n68035141fb21e5da4dcaf7bf57494e5455608abc8a9916ffd8e23d`r`n0a68ab79088aa7d5d5c2a0add4c9b3c27255740277f6edf8629596`r`n821ca04340a7c91e88b14ba087e0bfb04b57824193d842e660c419`r`nb8af4562cb13609a2ca469bf36fb8da2eda6f5e978bf1205660302"
$rarreg64 = "$loc64\rarreg.key"
$rarreg32 = "$loc32\rarreg.key"

$keygen = $null
$keygenUrl = $null
$keygen64 = "./bin/winrar-keygen/winrar-keygen-x64.exe"
$keygen32 = "./bin/winrar-keygen/winrar-keygen-x86.exe"
$keygenUrl32 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x86.exe"
$keygenUrl64 = "https://github.com/bitcookies/winrar-keygen/releases/latest/download/winrar-keygen-x64.exe"

$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"
$link_howtouse = "https://github.com/neuralpain/oneclickwinrar#how-to-use"
$link_namepattern = "https://github.com/neuralpain/oneclickwinrar#naming-patterns"
$link_overwriting = "https://github.com/neuralpain/oneclickwinrar#overwriting-licenses"
#endregion

#region Switch Configs
$script:WINRAR_IS_INSTALLED = $false
$script:WINRAR_INSTALLED_LOCATION = $null

$script:licensee = $null
$script:license_type = $null
$script:CUSTOM_LICENSE = $false
$script:OVERWRITE_LICENSE = $false
#endregion

#region Utility
#####UTILITIES#####
#####CONFIRM_QUERY#####
#endregion

#region Title
#####TITLE_HEADER#####
#endregion

#region Messages
#####MESSAGES#####
#endregion

#region Location and Defaults
#####LOCATIONS#####
#####SELECT_WINRAR_INSTALLATION#####
#endregion

#region Licensing
#####LICENSING#####
#endregion

#region Begin Execution
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
  if ($config.Count -gt 1 -and ($script:licensee.Length -eq 0 -or $script:license_type.Length -eq 0)) {
    &$Error_InvalidLicenseData
  }
}

Start-WinrarLicensing

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
#endregion
