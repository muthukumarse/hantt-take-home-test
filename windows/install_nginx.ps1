# PowerShell script to install Nginx on Windows Server with SSL
$ErrorActionPreference = "Stop"

# 0. Allow Port 80 and 443 in Firewall (Do this first!)
New-NetFirewallRule -DisplayName "Allow Nginx HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "Allow Nginx HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -Profile Any

# 0.1 Disable IIS (if present) to prevent P80 conflict
Stop-Service -Name W3SVC -Force -ErrorAction SilentlyContinue
Set-Service -Name W3SVC -StartupType Disabled -ErrorAction SilentlyContinue

# 1. Install Chocolatey with Retry Logic - hell didn't work well many time
# recommandation from reddit
$MaxRetries = 3
$RetryCount = 0
$Completed = $false

while (-not $Completed -and $RetryCount -lt $MaxRetries) {
    try {
        Write-Host "Attempting to install Chocolatey (Attempt $($RetryCount + 1)/$MaxRetries)..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $Completed = $true
        Write-Host "Chocolatey installed successfully."
    } catch {
        Write-Warning "Chocolatey installation failed: $_"
        $RetryCount++
        if ($RetryCount -lt $MaxRetries) {
            Write-Host "Retrying in 10 seconds..."
            Start-Sleep -Seconds 10
        } else {
            Throw "Failed to install Chocolatey after $MaxRetries attempts."
        }
    }
}

$env:Path = $env:Path + ";$env:ALLUSERSPROFILE\chocolatey\bin"

# 2. Install OpenSSL
choco install openssl.light -y
$env:Path = $env:Path + ";C:\Program Files\OpenSSL\bin"

# 3. Download and Extract Nginx
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

# 4. Generate SSL Certificates using OpenSSL
$CertDir = "$InstallDir\conf"
$KeyPath = "$CertDir\nginx.key"
$CrtPath = "$CertDir\nginx.crt"
$OpenSSLConfig = "$env:TEMP\openssl.cnf"

# Create a minimal OpenSSL config for the cert
@"
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = State
L = City
O = Organization
OU = OrgUnit
CN = example.com
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = example.com
"@ | Out-File -FilePath $OpenSSLConfig -Encoding ASCII

# Find OpenSSL Path
$OpenSSLPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
if (-not (Test-Path $OpenSSLPath)) {
    $OpenSSLPath = "C:\Program Files\OpenSSL\bin\openssl.exe"
}
if (-not (Test-Path $OpenSSLPath)) {
    Throw "OpenSSL not found at $OpenSSLPath"
}
Write-Host "Using OpenSSL at $OpenSSLPath"

# Generate Key and Cert
& $OpenSSLPath req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $KeyPath -out $CrtPath -config $OpenSSLConfig

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
# This is crucial so the new instance generates its own unique ID
Write-Host "Cleaning up SSM Agent state for AMI..."
Stop-Service -Name "AmazonSSMAgent" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\Amazon\SSM\*" -Recurse -Force -ErrorAction SilentlyContinue

