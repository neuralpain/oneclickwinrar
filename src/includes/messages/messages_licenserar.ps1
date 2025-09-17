$Error_UnknownScript = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "What script is this?" -ToastText  "Script name is invalid. Check the script name for any typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Script name is invalid. Please check for errors."
}

$Error_InvalidLicenseData = {
  New-Toast -ActionButtonUrl $link_namepattern -ToastTitle "Licensing error" -ToastText "Custom lincense data is invalid. Check the license data and try again."
  Stop-OcwrOperation -ExitType Error -Message
}

$Error_LicenseExists = {
  New-Toast -LongerDuration -ToastTitle "Unable to license WinRAR" -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

$Error_BinFolderMissing = {
  New-Toast -ActionButtonUrl $link_howtouse -ToastTitle "Missing `"bin`" folder" -ToastText  "Unable to generate a license. Ensure that the `"bin`" file is available in the same directory as the script."
  Stop-OcwrOperation -ExitType Warning -Message "Missing `"bin`" folder"
}

$Error_TooManyArgs = {
  New-Toast -LongerDuration -ActionButtonUrl $link_configuration -ToastTitle "Too many arguments!" -ToastText "It seems like you've made a configuration error. Check the configuration data and try again."
  Stop-OcwrOperation -ExitType Error -Message "Too many arguments. Check your configuration."
}