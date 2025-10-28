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

  $list = @()
  $files = Get-ChildItem -Path $pwd | Where-Object { $_.Name -match $name_pattern }

  if ($script:CUSTOM_INSTALLATION) {
    $download_pattern = "$($name)$($script:RARVER)$($script:TAGS).exe"
    foreach ($file in $files) {
      if ($file -match $download_pattern) { $list += $file }
    }
  } else {
    foreach ($file in $files) {
      if ($file -match $file_pattern) { $list += $file }
    }
  }

  return $($list | Sort-Object -Descending)[0]
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
    catch { $script:OCWR_ERROR = [ConnectionStatus]::DownloadAborted }

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
  } else { $script:OCWR_ERROR = [ConnectionStatus]::Disconnected }  # throw an error; fill the error variable
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
    if ($Error -or $script:OCWR_ERROR) { # will catch the first error from the attempt with server 1
      $Error.Clear()
      $script:OCWR_ERROR = $null # clear this regardless of the situation of the error
      $local:retrycount++
      Write-Host "Failed. Retrying... $local:retrycount"
      Get-WinrarInstaller -HostUri $server2_host -HostUriDir $wdir
    }
  }

  switch ($script:OCWR_ERROR) {
    [ConnectionStatus]::DownloadAborted {
      &$Error_UnableToConnectToDownload
    }
    [ConnectionStatus]::NoInternet {
      &$Error_NoInternetConnection
    }
    [ConnectionStatus]::Disconnected {
      &$Error_NoInternetConnection
    }
    Default {
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
  }
}

function Invoke-OwcrInstallation {
  <#
    .DESCRIPTION
      Installation instructions to be executed.
  #>

  # This ensures that the script does not unnecessarily
  # download a new installer if one is available in the
  # current directory
  $script:WINRAR_EXE = (Get-LocalWinrarInstaller)

  # if there are no installers, proceed to download one
  if ($null -eq $script:WINRAR_EXE) {
    Invoke-DownloadWinrarExecutable
    if (-not $script:DOWNLOAD_ONLY) {
      Invoke-OwcrInstallation; break
    }
    else {
      New-Toast -ToastTitle "Download Complete" `
                -ToastText  "WinRAR $($local:version) ($script:ARCH) was successfully downloaded." `
                -ToastText2 "Run this script again if you ever need to install it."
      $script:WINRAR_EXE = (Get-LocalWinrarInstaller)
      Write-Info "Download saved to $(Format-Text "'$(Format-Text "$pwd\$script:WINRAR_EXE" -Formatting Underline)'" -Foreground White)"
      Stop-OcwrOperation -ExitType Complete
    }
  } else {
    Write-Info "Found executable with version $(Format-Text (Format-VersionNumberFromExecutable $script:WINRAR_EXE) -Foreground White -Formatting Underline)"
    if ($script:DOWNLOAD_ONLY) {
      New-Toast -ToastTitle "Download Aborted" `
                -ToastText  "An installer for WinRAR $(Format-VersionNumberFromExecutable $script:WINRAR_EXE) ($script:ARCH) already exists." `
                -ToastText2 "Check the requested download version and try again."
      Stop-OcwrOperation -ExitType Warning -Message "An installer for WinRAR $(Format-VersionNumberFromExecutable $script:WINRAR_EXE) ($script:ARCH) in $(Get-LanguageName) already exists"
    }
  }

  Invoke-Installer $script:WINRAR_EXE (Format-VersionNumberFromExecutable $script:WINRAR_EXE)

#####INSTALLATION_SET_LOCATION#####
}