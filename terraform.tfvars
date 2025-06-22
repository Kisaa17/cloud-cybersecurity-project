# AWS Configuration
aws_region = "eu-north-1"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"

# Project Configuration
environment  = "dev"
project_name = "aws-cybersec"

# Security Configuration
# IMPORTANT: Change this to your actual IP address
my_ip_address = "0.0.0.0/0"  # Replace with your IP address (e.g., "203.0.113.0/32")

# EC2 Configuration
key_name      = "sakis"  # Replace with your existing key pair name
instance_type = "t3.micro" 