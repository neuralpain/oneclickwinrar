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
      $script:SPECIAL_CODE_ACTIVE = $true
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
      break
    }
    1 {
      $script:SPECIAL_CODE_ACTIVE = $true
      Write-Host -NoNewLine "Un-licensing WinRAR... "
      if (Test-Path "$rarloc\rarreg.key" -PathType Leaf) {
        Remove-Item "$rarloc\rarreg.key" -Force | Out-Null
        New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
        &$UnlicenseSuccess
      } else { &$Error_UnlicenseFailed }
      break
    }
    2 {
      $script:SPECIAL_CODE_ACTIVE = $true
      $script:SKIP_LICENSING = $true
      break
    }
    3 {
      $script:SPECIAL_CODE_ACTIVE = $true
      $script:LICENSE_ONLY = $true
      break
    }
    4 {
      $script:SPECIAL_CODE_ACTIVE = $true
      Update-WinrarLatestVersion
      break
    }
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
      break
    }
  }
}