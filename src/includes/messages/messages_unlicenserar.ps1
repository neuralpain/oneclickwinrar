$link_configuration = "https://github.com/neuralpain/oneclickwinrar#configuration"

$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_configuration" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again." 
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$UninstallSuccess = {
  New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."
  Stop-OcwrOperation -ExitType Complete
}

$Error_UninstallerMissing = {
  New-Toast -ToastTitle "WinRAR uninstaller is missing" -ToastText "WinRAR may not be installed correctly." -ToastText2 "Verify installation at $($rarloc)"
  Stop-OcwrOperation -ExitType Error -Message "WinRAR uninstaller is missing"
}

$UnlicenseSuccess = {
  New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
  Stop-OcwrOperation -ExitType Complete
}

$Error_UnlicenseFailed = {
  New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."
  Stop-OcwrOperation -ExitType Error -Message "No license found."
}

$Error_WinrarNotInstalled = {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR is not installed."
}