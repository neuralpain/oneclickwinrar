enum ConnectionStatus {
  Connected;
  NoInternet;
  DownloadAborted;
  Disconnected;
  CannotResolveHost;
}

$script:OCWR_ERROR = $null

enum OcwrStatus {
  Normal;
  SkipUpdates;
  Error;
}

$script:OCWR_STATUS = [OcwrStatus]::Normal
