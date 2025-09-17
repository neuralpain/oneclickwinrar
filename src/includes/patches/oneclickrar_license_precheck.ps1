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