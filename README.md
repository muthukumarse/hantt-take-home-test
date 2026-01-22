# DevOps Take-Home Test

This repository contains the infrastructure automation for deploying an Nginx web server on both Amazon Linux 2 and Windows Server 2019 using Packer, Terraform, Ansible, and GitHub Actions.

## Prerequisites (Manual Setup)

Before running the pipeline, you must manually set up the following in your AWS Account (`us-east-1`):

### 1. Create S3 Bucket for Terraform State
Create an S3 bucket to store the Terraform state file.
- **Bucket Name**: `devops-exercise-tf-state-<your-name>` (Update `terraform/providers.tf` if different).
- **Region**: `us-east-1`.
- **Versioning**: Enabled (Recommended).

### 2. Create EC2 Key Pair
Create a key pair to access the instances (SSH/RDP).
- **Name**: `my-key-pair`
- **Type**: RSA
- **Format**: `.pem`
- **Action**: Download the `.pem` file to your local machine. You will need this to decrypt the Windows Administrator password.

## Project Structure
```
├── .github/
│   └── workflows/
│       ├── create.yml      # CI/CD: Build and Deploy Infrastructure
│       └── destroy.yml     # CI/CD: Destroy Infrastructure
├── ansible/
│   ├── playbook.yml        # Ansible: Linux Nginx Installation
│   └── templates/
│       └── nginx.conf.j2   # Ansible: Nginx Config Template
├── packer/
│   ├── aws-linux-nginx.pkr.hcl  # Packer: Linux AMI Template
│   ├── windows-nginx.pkr.hcl    # Packer: Windows AMI Template
│   ├── variables.pkr.hcl        # Packer: Common Variables
│   ├── plugins.pkr.hcl          # Packer: Plugin Requirements
│   └── bootstrap_winrm.txt      # Packer: WinRM Bootstrap Script
├── terraform/
│   ├── compute.tf          # TF: EC2, SG, IAM
│   ├── networking.tf       # TF: VPC, Subnets, IGW, Routes
│   ├── variables.tf        # TF: Input Variables
│   ├── outputs.tf          # TF: Output Values
│   ├── providers.tf        # TF: AWS Provider & State Config
│   └── windows_user_data.txt # TF: Windows Boot Script (User Data)
├── windows/
│   ├── install_nginx.ps1   # Windows: Setup Script (Nginx, SSM, Firewall)
│   ├── nginx.conf          # Windows: Nginx Configuration
│   ├── nginx.crt           # Windows: SSL Certificate (Local)
│   └── nginx.key           # Windows: SSL Key (Local)
├── scripts/
│   └── validate_local.sh   # Utility: Local Validation Script
├── .gitignore              # Git: Ignored Files
├── deliverable.md          # Doc: Deliverable Checklist
└── README.md               # Doc: Project Documentation
```

## Architectural Decisions

### Windows Strategy
1.  **Local SSL Certificates**: 
    - We generate self-signed certificates locally and upload them to the Windows AMI during the Packer build.
    - *Why?* Installing OpenSSL via Chocolatey on Windows proved unreliable due to frequent CDN timeouts (504/503 errors).
2.  **SSM over RDP**: 
    - We prioritize AWS Systems Manager (SSM) for management. Use `Session Manager` in the AWS Console to connect.
    - *Why?* More secure than opening RDP (Port 3389) to the world. RDP is restricted to your specific IP.
3.  **IIS vs Nginx**: 
    - We explicitly disable the Windows `W3SVC` (IIS) service at boot.
    - *Why?* Sysprep often re-enables IIS, which grabs Port 80 and prevents Nginx from starting.
4.  **User Data Scheduling**: 
    - We explicitly schedule `InitializeInstance.ps1` to run checking User Data on the next boot.
    - *Why?* Ensures the SSM Agent is correctly started and registered when a new instance launches from the AMI.

## Accessing the Servers

### Linux
- **Connect**: Use Session Manager (AWS Console) OR SSH.
- **SSH Command**: `ssh -i my-key-pair.pem ec2-user@<public-ip>`
- **Verify**: Open `http://<public-ip>` in your browser.

### Windows
- **Connect**: Use Session Manager (AWS Console).
- **RDP Access**: Allowed only from your IP (configured in `terraform/compute.tf`).
    - **Username**: `Administrator`
    - **Password**: Decrypt using the `my-key-pair.pem` file in AWS Console.
- **Verify**: Open `http://<public-ip>` in your browser.

## Pipelines (GitHub Actions)

### 1. Create Infra - Build AMI & Deploy
This workflow builds the custom AMIs (Linux & Windows) and deploys the infrastructure.
- **Trigger**: Go to **Actions** -> **Create Infra - Build AMI & Deploy** -> **Run workflow**.
- **Inputs**:
    - **Build Linux & Windows AMI ?**: Select `Yes` to build fresh AMIs.
    - **Deploy Nginx Web Server ?**: Select `Yes` to deploy with Terraform.

### 2. Destroy Infra
Destroys all infrastructure to clean up.
