# Deliverable Resources

Here is the list of resources created by the automation. You can use this list to take screenshots for your final deliverable.

## AMIs Created (Packer)
1.  **Linux AMI**: `devops-exercise-nginx-<timestamp>`
    *   Base: Amazon Linux 2
    *   Software: Nginx, Python 3.8
2.  **Windows AMI**: `devops-exercise-windows-<timestamp>`
    *   Base: Windows Server 2019
    *   Software: Nginx

## AWS Infrastructure Resources (Terraform)

### Network
*   **VPC**: `devops-exercise-vpc`
*   **Internet Gateway**: `devops-exercise-igw`
*   **Public Subnet**: `devops-exercise-public-subnet` (in `us-east-1a`)
*   **Private Subnet**: `devops-exercise-private-subnet` (in `us-east-1a`)
*   **Route Table**: `devops-exercise-public-rt`

### Security & IAM
*   **Security Group**: `devops-exercise-web-sg`
    *   Inbound: 80, 443, 22 (All IPs), 3389 (Your IP)
*   **IAM Role**: `devops-exercise-ec2-role`
*   **IAM Instance Profile**: `devops-exercise-ec2-profile`

### Compute
*   **EC2 Instance (Linux)**: `devops-exercise-linux-web`
*   **EC2 Instance (Windows)**: `devops-exercise-windows-web`

## Screenshots Required
Based on the list above, you should take screenshots of:
1.  **AMI Console**: Showing both custom AMIs.
2.  **EC2 Dashboard**: Showing both running instances.
3.  **VPC Dashboard**: Showing the VPC, Subnets, and Route Tables.
4.  **Security Groups**: Showing the rules for the web security group.
