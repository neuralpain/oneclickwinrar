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

  $local:rarloc = $script:WINRAR_INSTALLED_LOCATION

  switch ($script:custom_code) {
    0 {
      $script:SPECIAL_CODE_ACTIVE = $true
      if ($script:WINRAR_IS_INSTALLED) {
        #####UNINSTALLATION#####
      } else { &$Error_WinrarNotInstalled }
      break
    }
    1 {
      $script:SPECIAL_CODE_ACTIVE = $true
      #####UNLICENSING#####
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