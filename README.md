# DevOps Exercise - Nginx on Linux & Windows

This project provisions a dual-platform environment (Linux & Windows) running Nginx, using Terraform, Ansible, and Packer, automated via GitHub Actions.

## Project Structure

- `terraform/`: Infrastructure components (AWS VPC, EC2, SG).
- `ansible/`: Configuration management for Amazon Linux 2 (Nginx + SSL).
- `packer/`: AMI build templates.
    - `aws-linux-nginx.pkr.hcl`: Builds Amazon Linux 2 AMI using Ansible.
    - `windows-nginx.pkr.hcl`: Builds Windows Server 2019 AMI using PowerShell.
- `windows/`: PowerShell scripts and config for Windows Nginx setup.
- `.github/workflows/`: CI/CD pipeline.

## Prerequisites

1.  **AWS Credentials**: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` stored as GitHub Secrets.
2.  **GitHub Actions**: Enabled for the repository.

## How to Deploy

The deployment is automated via the **DevOps Exercise Pipeline** GitHub Action.

### 1. Build AMIs
Go to **Actions** -> **DevOps Exercise Pipeline** -> **Run workflow**.
- Select **Yes** for `build_ami`.
- (Optional) Select **No** for `confirm_deploy` if you only want to build images.

This will build two AMIs:
- `devops-exercise-nginx-<timestamp>` (Linux)
- `devops-exercise-windows-<timestamp>` (Windows)

### 2. Deploy Infrastructure
Go to **Actions** -> **DevOps Exercise Pipeline** -> **Run workflow**.
- Select **No** for `build_ami` (if already built).
- Select **Yes** for `confirm_deploy`.

This will run `terraform apply` and provision:
- 1 x Linux EC2 public instance
- 1 x Windows EC2 public instance

## Verification

### Check Outputs
The GitHub Action logs (or local `terraform output`) will display:
- `linux_public_ip`
- `windows_public_ip`

### Verify Linux
```bash
curl -k https://<linux_public_ip>
# Should return Nginx welcome page
```

### Verify Windows
1.  **HTTPS**: Open `https://<windows_public_ip>` in a browser (accept simple self-signed cert warning).
2.  **RDP**: Connect to `<windows_public_ip>` via RDP (Port 3389).
    - Username: `Administrator`
    - Password: (Get from AWS Console -> Connect -> RDP Client -> Get Password using your Key Pair)