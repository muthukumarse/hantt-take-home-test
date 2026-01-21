# Deliverables

This document consolidates the deliverables for the DevOps exercise.

## 1. Terraform Template
The Terraform configuration can be found in the [terraform directory](./terraform).
Key files:
- [terraform/networking.tf](./terraform/networking.tf): VPC and Subnets.
- [terraform/compute.tf](./terraform/compute.tf): EC2 and IAM.

## 2. Ansible Script
The Ansible playbook used to configure Nginx is located at [ansible/playbook.yml](./ansible/playbook.yml).
It uses the template at [ansible/templates/nginx.conf.j2](./ansible/templates/nginx.conf.j2).

## 3. & 4. Screenshots
*Please run the deployment in your AWS account to generate the resources and capture the following screenshots:*

### AWS Resources
- **VPC Console**: Show the `devops-exercise-vpc`, public/private subnets.
- **EC2 Console**: Show the `devops-exercise-web-server` instance in `running` state.

### Nginx Validation
- **Browser/Terminal**: Show the result of `curl -k https://<instance_ip>` or a browser window accessing the IP, demonstrating that Nginx is serving content over HTTPS with the self-signed certificate.
