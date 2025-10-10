#####SHARED_MESSAGES#####

$Error_UnknownError = {
  Stop-OcwrOperation -ExitType Error -Message "An unknown error occured."
}

$Error_UnableToProcess = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process data" -ToastText "WinRAR data is invalid." -ToastText2 "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "WinRAR data is invalid."
}

$Error_UnableToProcessSpecialCode = {
  New-Toast -ActionButtonUrl "$link_configuration" -ToastTitle "Unable to process special code" -ToastText "Check your configuration for any errors or typos and try again."
  Stop-OcwrOperation -ExitType Error -Message "Unable to process special code."
}

#####MESSAGES_INSTALLRAR#####

$Error_ButLicenseExists = {
  New-Toast -LongerDuration -ToastTitle "WinRAR installed successfully but.." -ActionButtonUrl $link_overwriting -ToastText  "Notice: A WinRAR license already exists." -ToastText2 "View the documentation on how to use the override switch to install a new license."
  Stop-OcwrOperation -ExitType Warning -Message "Unable to license WinRAR due to existing license."
}

#####MESSAGES_LICENSERAR#####

#####MESSAGES_UNLICENSERAR#####
