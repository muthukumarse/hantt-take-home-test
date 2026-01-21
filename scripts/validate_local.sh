#!/bin/bash
set -e

echo "=== Starting Local Validation ==="

# 1. Terraform Validation
echo "--- Validating Terraform ---"
if command -v terraform &> /dev/null; then
    cd terraform
    terraform init -backend=false
    terraform validate
    cd ..
else
    echo "Error: Terraform is not installed."
    exit 1
fi

# 2. Packer Validation
echo "--- Validating Packer ---"
if command -v packer &> /dev/null; then
    cd packer
    packer init .
    packer validate .
    cd ..
else
    echo "Error: Packer is not installed."
    exit 1
fi

# 3. Ansible Validation
echo "--- Validating Ansible ---"
if command -v ansible-playbook &> /dev/null; then
    ansible-playbook ansible/playbook.yml --syntax-check
else
    echo "Warning: Ansible is not installed. Skipping Ansible validation."
fi

echo "=== All Validations Passed Successfully! ==="

# TODO: Add Packer build and Ansible run
# Skipping for now