function Write-Info{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "INFO: $Message" -ForegroundColor DarkCyan}
function Write-Warn{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "WARN: $Message" -ForegroundColor Yellow}
function Write-Err{Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message);Write-Host "ERROR: $Message" -ForegroundColor Red}
