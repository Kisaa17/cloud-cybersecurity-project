terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  environment          = var.environment
  project_name         = var.project_name
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  my_ip_address    = var.my_ip_address
  environment      = var.environment
  project_name     = var.project_name
}

# EC2 Instances Module
module "ec2_instances" {
  source = "./modules/ec2_instances"
  
  vpc_id                    = module.vpc.vpc_id
  public_subnet_id          = module.vpc.public_subnet_id
  private_subnet_id         = module.vpc.private_subnet_id
  public_security_group_id  = module.security_groups.public_security_group_id
  private_security_group_id = module.security_groups.private_security_group_id
  key_name                  = var.key_name
  instance_type             = var.instance_type
  environment               = var.environment
  project_name              = var.project_name
} 