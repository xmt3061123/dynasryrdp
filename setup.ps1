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
$scriptBlock = {
    param (
        [string]$url,
        [string]$fileName,
        [string]$installArgs
    )

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

    Download-And-Install -url $using:url -fileName $using:fileName -installArgs $using:installArgs
}

# Start parallel jobs
$job1 = Start-Job -ScriptBlock $scriptBlock -ArgumentList "https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi", "chromeremotedesktophost.msi", ""
$job2 = Start-Job -ScriptBlock $scriptBlock -ArgumentList "https://dl.google.com/chrome/install/latest/chrome_installer.exe", "chrome_installer.exe", "/install"

# Wait for all jobs to complete
Wait-Job -Job $job1, $job2

# Output job results
Receive-Job -Job $job1, $job2

# Clean up jobs
Remove-Job -Job $job1, $job2
