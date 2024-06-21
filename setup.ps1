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
        Start-Process -FilePath $tempPath -ArgumentList $installArgs -Verb RunAs -Wait -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to download or install ${fileName}: $_"
    }
    finally {
        if (Test-Path $tempPath) {
            Remove-Item $tempPath -Force
            Write-Output "${fileName} has been removed from temp"
        }
    }
}

# 使用后台作业并行下载和安装
$job1 = Start-Job -ScriptBlock {
    Download-And-Install -url "https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi" -fileName "chromeremotedesktophost.msi"
}

$job2 = Start-Job -ScriptBlock {
    Download-And-Install -url "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -fileName "chrome_installer.exe" -installArgs "/install"
}

# 等待所有作业完成
Wait-Job -Job $job1, $job2

# 输出作业结果
Receive-Job -Job $job1, $job2

# 清理作业
Remove-Job -Job $job1, $job2
