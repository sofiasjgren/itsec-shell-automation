$LogFile = "user_check.log"
$FoundCount = 0
$MissingCount = 0

function Write-Log {
    param([string]$Message)

    $entry = "$(Get-Date) - $Message"
    $entry | Tee-Object -FilePath $LogFile -Append
}

function Check-User {
    param([string]$UserName)

    try {
        $null = Get-LocalUser -Name $UserName -ErrorAction Stop
        Write-Log "Användaren '$UserName' finns."
        $script:FoundCount++
    }
    catch {
        Write-Log "VARNING: Användaren '$UserName' saknas."
        $script:MissingCount++
    }
}

function Run-Checks {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Log "FEL: Filen '$Path' saknas."
        exit
    }

    foreach ($user in Get-Content $Path) {
        if (-not [string]::IsNullOrWhiteSpace($user)) {
            Check-User -UserName $user.Trim()
        }
    }
}

Clear-Content -Path $LogFile -ErrorAction SilentlyContinue
Write-Log "Startar användarkontroll."
Run-Checks "userlist.txt"
Write-Log "Sammanfattning: $FoundCount användare finns, $MissingCount användare saknas."
Write-Log "Kontroller slutförda."