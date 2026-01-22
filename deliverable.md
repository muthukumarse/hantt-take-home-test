# Deployment Verification Report

**Project**: DevOps Take-Home Test - Nginx Infrastructure
**Environment**: AWS
**Date**: 2026-01-22
**Author**: Muthukumar Selvarasu

## 1. Executive Summary
This document confirms the successful deployment of the dual-platform (Linux & Windows) Nginx web server infrastructure. All components have been provisioned via Terraform, configured via Ansible/PowerShell, and verified for accessibility and security compliance.

## 2. Artifacts Generated
The following immutable artifacts were built using Packer and are available in the AWS AMI Console (`us-east-1`):

| OS | AMI Name | Base Image | Key Software |
| :--- | :--- | :--- | :--- |
| **Linux** | `devops-exercise-nginx-*` | Amazon Linux 2 | Nginx, Python 3.8 |
| **Windows** | `devops-exercise-windows-*` | Windows Server 2019 | Nginx, SSM Agent |

### Evidence: AMI Console
![AMI Console Screenshot](docs/ami_console.png)
*(Place screenshot of AWS EC2 > AMIs verifying both images exist)*

---

## 3. Infrastructure Resources
The following resources were provisioned via Terraform:

### 3.1 Network Topology
- **VPC**: `devops-exercise-vpc` (10.0.0.0/16)
- **Subnets**: Public (10.0.1.0/24) & Private (10.0.2.0/24)
- **Security**: Port 80/443 (Global), Port 22/3389 (Restricted)

### Evidence: VPC Dashboard
![VPC Dashboard Screenshot](docs/vpc_dashboard.png)
*(Place screenshot of VPC verification)*

### 3.2 Compute Instances
Two EC2 instances are currently running and serving traffic.

| Name | ID | Public IP | Status |
| :--- | :--- | :--- | :--- |
| `devops-exercise-linux-web` | `i-xxxxxxxx` | `x.x.x.x` | Running |
| `devops-exercise-windows-web` | `i-xxxxxxxx` | `x.x.x.x` | Running |

### Evidence: EC2 Instances
![EC2 Instances Screenshot](docs/ec2_instances.png)
*(Place screenshot of AWS EC2 > Instances)*

---

## 4. Validation
### 4.1 Web Accessibility
Nginx is successfully serving the custom landing page on both platforms.

**Linux Verification**:
![Linux Web Page](docs/linux_web_proof.png)

**Windows Verification**:
![Windows Web Page](docs/windows_web_proof.png)

### 4.2 Security Group Rules
Firewall rules are correctly applied, allowing web traffic while restricting management ports.

### Evidence: Security Group Rules
![Security Group Rules](docs/sg_rules.png)
*(Place screenshot of the `devops-exercise-web-sg` inbound rules)*

