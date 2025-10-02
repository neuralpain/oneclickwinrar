#region General Messages
$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_UnknownError = {
  Stop-OcwrOperation -ExitType Error -Message "An unknown error occured."
}

$Error_WinrarNotInstalled = {
  New-Toast -ToastTitle "WinRAR is not installed" -ToastText "Check your installation and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR is not installed."
}

$Error_NoInternetConnection = {
  New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."
  Stop-OcwrOperation -ExitType Error -Message "Internet connection lost or unavailable."
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}

$Error_UnableToProcess = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR data is invalid."
}

$Error_UnableToProcessSpecialCode = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process special code" -ToastText "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Unable to process special code."
}
#endregion

#region Licensing Messages
$Error_LicenseExists = {
  New-Toast -LongerDuration -ToastTitle "Unable to license WinRAR" -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_ButLicenseExists = {
  New-Toast -LongerDuration -ToastTitle "WinRAR installed successfully but.." -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_BinFolderMissing = {
  New-Toast -ActionButtonUrl $link_howtouse -ToastTitle "Missing `"bin`" folder" -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."
  Stop-OcwrOperation -ExitType Warning -Message "Missing `"bin`" folder"
}
#endregion

#region Install Messages
$Error_No32bitSupport = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "No 32-bit support for this version of WinRAR."
}

$Error_InvalidVersionNumber = {
  New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number provided is greater than the latest version available."
  Stop-OcwrOperation -ExitType Error -Message "Invalid version number."
}

$Error_UnableToConnectToDownload = {
  New-Toast -ToastTitle "Unable to make a connection" -ToastText "Please check your internet or firewall rules."
  Stop-OcwrOperation -ExitType Error -Message "Unable to make a connection."
}
#endregion

#region Uninstall Messages
$UninstallSuccess = {
  New-Toast -ToastTitle "WinRAR uninstalled successfully" -ToastText "Run oneclickrar.cmd to reinstall."
  Stop-OcwrOperation -ExitType Complete
}

$UnlicenseSuccess = {
  New-Toast -ToastTitle "WinRAR unlicensed successfully" -ToastText "Enjoy your 40-day infinite trial period!"
  Stop-OcwrOperation -ExitType Complete
}

$Error_UninstallerMissing = {
  New-Toast -ToastTitle "WinRAR uninstaller is missing" -ToastText "WinRAR may not be installed correctly." -ToastText2 "Verify installation at $($rarloc)"
  Stop-OcwrOperation -ExitType Error -Message "WinRAR uninstaller is missing"
}

$Error_UnlicenseFailed = {
  New-Toast -ToastTitle "Unable to un-license WinRAR" -ToastText "A WinRAR license was not found on your device."
  Stop-OcwrOperation -ExitType Error -Message "No license found."
}
#endregion