# Define the SentinelOne uninstall command
$uninstallCmd = "C:\Program Files\SentinelOne\<version>\uninstall.exe"

# Define a log file to capture output
$logFile = "C:\temp\SentinelOne_Uninstall.log"

# Run the uninstall command quietly
Start-Process -FilePath $uninstallCmd -ArgumentList "/quiet" -Wait -NoNewWindow -RedirectStandardOutput $logFile

# Wait for a few seconds to ensure the uninstall completes
Start-Sleep -Seconds 30

# Function to remove registry entries
function Remove-RegistryEntries {
    $registryPaths = @(
        "HKLM:\Software\SentinelOne",
        "HKLM:\Software\WOW6432Node\SentinelOne",
        "HKCU:\Software\SentinelOne"
    )

    foreach ($path in $registryPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
        }
    }
}

# Function to remove files and directories
function Remove-FilesAndDirectories {
    $folders = @(
        "C:\Program Files\SentinelOne",
        "C:\Program Files (x86)\SentinelOne",
        "C:\ProgramData\SentinelOne",
        "C:\Users\$env:USERNAME\AppData\Local\SentinelOne",
        "C:\Users\$env:USERNAME\AppData\Roaming\SentinelOne"
    )

    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Remove-Item -Path $folder -Recurse -Force
        }
    }
}

# Remove SentinelOne registry entries
Remove-RegistryEntries

# Remove SentinelOne files and directories
Remove-FilesAndDirectories

# Restart the computer if required
$needsRestart = Get-EventLog -LogName System -Newest 1 -InstanceId 1074
if ($needsRestart) {
    Write-Output "Restarting computer..." | Out-File -FilePath $logFile -Append
    Restart-Computer -Force
}

# Verification function to ensure SentinelOne is completely removed
function Verify-Removal {
    $isInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*SentinelOne*" }
    if (-not $isInstalled) {
        Write-Output "SentinelOne uninstalled successfully." | Out-File -FilePath $logFile -Append
    } else {
        Write-Output "SentinelOne uninstallation failed." | Out-File -FilePath $logFile -Append
    }
}

# Verify the uninstallation
Verify-Removal
