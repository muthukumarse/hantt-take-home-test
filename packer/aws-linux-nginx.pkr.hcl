




source "amazon-ebs" "nginx" {
  ami_name      = "devops-exercise-nginx-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = "devops-exercise-builder"
  sources = [
    "source.amazon-ebs.nginx"
  ]

  provisioner "shell" {
    inline = [
      "sudo amazon-linux-extras enable python3.8",
      "sudo yum install -y python3.8",
      "sudo ln -sf /usr/bin/python3.8 /usr/bin/python3"
    ]
  }

  provisioner "ansible" {
    playbook_file = "../ansible/playbook.yml"
    user          = "ec2-user"
    use_proxy     = false
    extra_arguments = [
      "--extra-vars", "domain_name=example.com ansible_python_interpreter=/usr/bin/python3.8",
      "--scp-extra-args='-O'"
    ]
  }
}
