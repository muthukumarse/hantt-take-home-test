# PowerShell script to install Nginx on Windows Server with SSL
$ErrorActionPreference = "Stop"

# 0. Allow Port 80 and 443 in Firewall (Do this first!)
New-NetFirewallRule -DisplayName "Allow Nginx HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "Allow Nginx HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -Profile Any

# 0.1 Disable IIS (if present) to prevent P80 conflict
Stop-Service -Name W3SVC -Force -ErrorAction SilentlyContinue
Set-Service -Name W3SVC -StartupType Disabled -ErrorAction SilentlyContinue

# 1. Install Nginx (Direct Download, No Chocolatey)
# DECISION: We avoid Chocolatey here because the CDN is flaky and often causes 504 timeouts.
# Direct download is faster and more reliable for this test.
$NginxUrl = "http://nginx.org/download/nginx-1.24.0.zip"
$InstallDir = "C:\nginx"
$ZipPath = "$env:TEMP\nginx.zip"

Write-Host "Downloading Nginx..."
Invoke-WebRequest -Uri $NginxUrl -OutFile $ZipPath

Write-Host "Extracting Nginx..."
Expand-Archive -Path $ZipPath -DestinationPath "C:\" -Force

# Rename extracted folder (nginx-1.24.0 -> nginx)
$ExtractedDir = Get-ChildItem "C:\" -Filter "nginx-*" | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if ($ExtractedDir -and $ExtractedDir.Name -ne "nginx") {
    Rename-Item -Path $ExtractedDir.FullName -NewName "nginx" -Force
}

# 2. Setup SSL Certificates (Uploaded by Packer)
# DECISION: We generate certs locally and upload them via Packer
# to avoid installing OpenSSL on the VM (which depends on Chocolatey).
$CertDir = "$InstallDir\conf"
Write-Host "Moving SSL Certificates..."
if (Test-Path "C:\Windows\Temp\nginx.crt") {
    Move-Item -Path "C:\Windows\Temp\nginx.crt" -Destination "$CertDir\nginx.crt" -Force
} else {
    Write-Warning "nginx.crt not found in Temp!"
}
if (Test-Path "C:\Windows\Temp\nginx.key") {
    Move-Item -Path "C:\Windows\Temp\nginx.key" -Destination "$CertDir\nginx.key" -Force
} else {
    Write-Warning "nginx.key not found in Temp!"
}

# 5. Setup Nginx Configuration
# We assume the nginx.conf is uploaded to C:\Windows\Temp\nginx.conf by Packer
if (Test-Path "C:\Windows\Temp\nginx.conf") {
    Move-Item -Path "C:\Windows\Temp\nginx.conf" -Destination "$InstallDir\conf\nginx.conf" -Force
}

# 6. Create Scheduled Task to Start Nginx on Boot
$Action = New-ScheduledTaskAction -Execute "$InstallDir\nginx.exe" -WorkingDirectory $InstallDir
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
Register-ScheduledTask -TaskName "StartNginx" -Action $Action -Trigger $Trigger -Principal $Principal



# 8. Create Custom Index Page
$IndexFile = "$InstallDir\html\index.html"
$Content = @"
<html>
<head><title>Welcome to DevOps Exercise (Windows)</title></head>
<body>
<h1>Hello from Windows Server 2019!</h1>
<p>This page is served by Nginx securely via HTTPS.</p>
<p>Built with Packer and PowerShell.</p>
</body>
</html>
"@
Set-Content -Path $IndexFile -Value $Content

Write-Host "Nginx installation and configuration complete."

# 9. Ensure SSM Agent is running (It should be pre-installed on AWS AMIs)
Write-Host "Verifying SSM Agent..."
$ssmService = Get-Service -Name "AmazonSSMAgent" -ErrorAction SilentlyContinue
if ($ssmService) {
    Set-Service -Name "AmazonSSMAgent" -StartupType Automatic
    if ($ssmService.Status -ne "Running") {
        Start-Service -Name "AmazonSSMAgent"
    }
    Write-Host "SSM Agent is running."
} else {
    Write-Warning "AmazonSSMAgent service not found! This is unexpected for an AWS Windows AMI."
}

# 10. Clean up SSM Agent for AMI creation
# CRITICAL: We must remove the agent's state files. If we don't, every instance launched
# from this AMI will try to use the same SSM ID, causing conflicts.
Write-Host "Cleaning up SSM Agent state for AMI..."
Stop-Service -Name "AmazonSSMAgent" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\Amazon\SSM\*" -Recurse -Force -ErrorAction SilentlyContinue

# 11. Schedule User Data Execution for Next Boot
# This is CRITICAL. Without this, the new instance won't run the User Data script
# because it thinks it's already initialized.
Write-Host "Scheduling User Data execution..."
C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule


