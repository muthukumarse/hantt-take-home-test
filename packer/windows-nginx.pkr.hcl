# windows nginx ebs and build script

source "amazon-ebs" "windows-nginx" {
  ami_name      = "devops-exercise-windows-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_type = var.instance_type
  region        = var.aws_region
  
  # Windows Server 2019 Base
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"] # Amazon
  }

  communicator   = "winrm"
  winrm_username = "Administrator"
  winrm_use_ssl  = false
  winrm_insecure = true

  # User data to enable WinRM is critical
  user_data_file = "bootstrap_winrm.txt"
}

build {
  name = "devops-exercise-windows"
  sources = [
    "source.amazon-ebs.windows-nginx"
  ]

  # Upload Nginx Config
  provisioner "file" {
    source      = "../windows/nginx.conf"
    destination = "C:\\Windows\\Temp\\nginx.conf"
  }

  # Upload SSL Certs
  # Could not able to solve Chocolatey/OpenSSL issue, so this is better approach
  provisioner "file" {
    source      = "../windows/nginx.crt"
    destination = "C:\\Windows\\Temp\\nginx.crt"
  }

  provisioner "file" {
    source      = "../windows/nginx.key"
    destination = "C:\\Windows\\Temp\\nginx.key"
  }

  # Run Installation Script
  provisioner "powershell" {
    script = "../windows/install_nginx.ps1"
  }
  
  # Sysprep / Generalize (Optional but good practice, skipping for speed in this exercise)
  # didn't work well :( - Need to figure out how to make it work
  # provisioner "powershell" {
  #   inline = [
  #     "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
  #     "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -Region ${var.aws_region}"
  #   ]
  # }
}
