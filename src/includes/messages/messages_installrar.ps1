$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_configuration" -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_NoInternetConnection = {
  New-Toast -ToastTitle "No internet" -ToastText "Please check your internet connection."
  Stop-OcwrOperation -ExitType Error -Message "Internet connection lost or unavailable."
}

$Error_UnableToConnectToDownload = {
  New-Toast -ToastTitle "Unable to make a connection" -ToastText "Please check your internet or firewall rules."
  Stop-OcwrOperation -ExitType Error -Message "Unable to make a connection."
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}

$Error_No32bitSupport = {
  New-Toast -LongerDuration -ActionButtonUrl "$link_endof32bitsupport"  -ActionButtonText "Read More" -ToastTitle "Unable to process data" -ToastText "WinRAR no longer supports 32-bit on newer versions." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "No 32-bit support for this version of WinRAR."
}

$Error_InvalidVersionNumber = {
  New-Toast -ToastTitle "Unable to process data" -ToastText "The WinRAR version is invalid." -ToastText2 "The version number provided is greater than the latest version available."
  Stop-OcwrOperation -ExitType Error -Message "Invalid version number."
}