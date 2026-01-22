provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "devops-exercise-tf-state-muthu" # User must create this bucket!
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
