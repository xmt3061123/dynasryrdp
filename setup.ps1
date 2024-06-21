# 禁用防火墙
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# 定义下载和安装函数
function Download-And-Install {
    param (
        [string]$url,
        [string]$fileName,
        [string]$installArgs = ""
    )

    $tempPath = Join-Path -Path $env:TEMP -ChildPath $fileName
    try {
        Write-Output "Downloading $url to $tempPath"
        Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
        Write-Output "Starting installation of $fileName"

        if ($fileName -like "*.msi") {
            # Use msiexec for .msi files
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $tempPath, $installArgs, "/quiet", "/norestart" -Verb RunAs -Wait -ErrorAction Stop
        } else {
            # Use default start process for other file types
            Start-Process -FilePath $tempPath -ArgumentList $installArgs -Verb RunAs -Wait -ErrorAction Stop
        }

    } catch {
        Write-Error "Failed to download or install ${fileName}: $_"
    } finally {
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
            Write-Output "${fileName} has been removed from temp"
        }
    }
}

# 顺序下载和安装
Download-And-Install -url "https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi" -fileName "chromeremotedesktophost.msi"
#Download-And-Install -url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -fileName "chrome_installer.exe" -installArgs "/install"
