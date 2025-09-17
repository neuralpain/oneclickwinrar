function Invoke-OcwrLicensing {
  <#
    .DESCRIPTION
      Licensing instructions to be executed (if not disabled).
  #>

#####LICENSE_PRECHECK#####

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
#####EXISTING_LICENSE_ERROR#####
      }
  }
}