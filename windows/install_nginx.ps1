# PowerShell script to install Nginx on Windows Server
# Installs Nginx and configures it (basic setup)

$NginxUrl = "http://nginx.org/download/nginx-1.24.0.zip"
$InstallDir = "C:\nginx"
$ZipPath = "$env:TEMP\nginx.zip"

Write-Host "Downloading Nginx from $NginxUrl..."
Invoke-WebRequest -Uri $NginxUrl -OutFile $ZipPath

Write-Host "Extracting Nginx..."
Expand-Archive -Path $ZipPath -DestinationPath "C:\" -Force

# Rename the folder to remove version number for easier access
$ExtractedDir = Get-ChildItem "C:\" -Filter "nginx-*" | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if ($ExtractedDir) {
    Rename-Item -Path $ExtractedDir.FullName -NewName "nginx" -Force
}

# Create a self-signed certificate (basic example for Windows)
$Cert = New-SelfSignedCertificate -DnsName "example.com" -CertStoreLocation "cert:\LocalMachine\My"
$Thumbprint = $Cert.Thumbprint

Write-Host "Nginx installed at $InstallDir"
Write-Host "Self-signed certificate created with Thumbprint: $Thumbprint"

# Basic config update to point to SSL would require manipulating nginx.conf text file
# For this exercise, we'll just start Nginx
Start-Process "$InstallDir\nginx.exe"

Write-Host "Nginx started."
