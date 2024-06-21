# Disable Firewall Profiles
try {
    Write-Output "Disabling Firewall Profiles for Domain, Public, and Private..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Output "Firewall Profiles disabled successfully."
} catch {
    Write-Error "Failed to disable Firewall Profiles: $_"
    exit 1
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
} catch {
    Write-Error "Failed to install Chrome Remote Desktop Host: $_"
    exit 1
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
    Write-Error "Failed to install Google Chrome: $_"
    exit 1
}
