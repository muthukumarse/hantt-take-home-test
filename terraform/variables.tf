variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name tag"
  default     = "devops-exercise"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.0.2.0/24"
}



variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium" # Windows requires more resources
}

variable "key_name" {
  description = "SSH Key Pair name"
  default     = "my-key-pair" # User should ensure this exists or we can create one (optional)
}

variable "my_ip" {
  description = "Your public IP address (CIDR format) for RDP/SSH access"
  default     = "0.0.0.0/0" # Change this to your actual IP, e.g., "1.2.3.4/32"
}
