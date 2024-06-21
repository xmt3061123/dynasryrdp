# setup.ps1

# Function to log and exit on error
function Log-Error {
    param (
        [string]$Message
    )
    Write-Error $Message
    exit 1
}

# Disable Firewall Profiles
try {
    Write-Output "Disabling Firewall Profiles for Domain, Public, and Private..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Output "Firewall Profiles disabled successfully."
} catch {
    Log-Error "Failed to disable Firewall Profiles: $_"
}

# Download and Install Chrome Remote Desktop Host
try {
    $remoteDesktopInstaller = "$env:TEMP\chromeremotedesktophost.msi"
    Write-Output "Downloading Chrome Remote Desktop Host..."
    Invoke-WebRequest -Uri 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi' -OutFile $remoteDesktopInstaller
    Write-Output "Installing Chrome Remote Desktop Host..."
    Start-Process -FilePath $remoteDesktopInstaller -ArgumentList "/quiet /norestart" -Wait
    Write-Output "Cleaning up installer..."
    Remove-Item -Path $remoteDesktopInstaller
    Write-Output "Chrome Remote Desktop Host installed successfully."
    
    # Confirm the installation path and save it to an environment variable
    $crdPath = "${Env:ProgramFiles(x86)}\Google\Chrome Remote Desktop\CurrentVersion\remoting_start_host.exe"
    if (Test-Path $crdPath) {
        Write-Output "Chrome Remote Desktop Host found at $crdPath."
        [System.Environment]::SetEnvironmentVariable('CRD_PATH', $crdPath, [System.EnvironmentVariableTarget]::Machine)
    } else {
        Log-Error "Chrome Remote Desktop Host not found at expected path: $crdPath"
    }
} catch {
    Log-Error "Failed to install Chrome Remote Desktop Host: $_"
}

# Download and Install Google Chrome
try {
    $chromeInstaller = "$env:TEMP\chrome_installer.exe"
    Write-Output "Downloading Google Chrome..."
    Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile $chromeInstaller
    Write-Output "Installing Google Chrome..."
    Start-Process -FilePath $chromeInstaller -ArgumentList '/silent /install' -Verb RunAs -Wait
    Write-Output "Cleaning up installer..."
    Remove-Item -Path $chromeInstaller
    Write-Output "Google Chrome installed successfully."
} catch {
    Log-Error "Failed to install Google Chrome: $_"
}
