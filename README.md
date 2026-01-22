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

## Pipelines (GitHub Actions)

### 1. Create Infra - Build AMI & Deploy
This workflow builds the custom AMIs (Linux & Windows) and deploys the infrastructure.
- **Trigger**: Go to **Actions** -> **Create Infra - Build AMI & Deploy** -> **Run workflow**.
- **Inputs**:
    - **Build Linux & Windows AMI ?**: Select `Yes` to build fresh AMIs (takes ~15 mins). Select `No` to reuse existing AMIs.
    - **Deploy Nginx Web Server ?**: Select `Yes` to run Terraform apply.

### 2. Destroy Infra
This workflow destroys all infrastructure created by Terraform.
- **Trigger**: Go to **Actions** -> **Destroy Infra** -> **Run workflow**.
- **Input**: Select `Yes` to confirm destruction.

## Accessing the Servers

### Linux
- **Connect**: Use Session Manager (AWS Console) OR SSH.
- **SSH Command**: `ssh -i my-key-pair.pem ec2-user@<public-ip>`
- **Verify**: Open `http://<public-ip>` in your browser.

### Windows
- **Connect**: Use RDP.
    - **Username**: `Administrator`
    - **Password**: Decrypt using the `my-key-pair.pem` file in AWS Console.
- **Verify**: Open `http://<public-ip>` in your browser.

## Architecture
- **Packer**: Builds immutable AMIs with Nginx pre-installed.
- **Terraform**: Provisions VPC, Subnets, Security Groups, IAM Roles, and EC2 Instances.
- **Ansible/PowerShell**: Configures Nginx and installs necessary agents.
- **GitHub Actions**: Orchestrates the entire lifecycle.
