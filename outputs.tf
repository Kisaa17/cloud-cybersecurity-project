output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

output "public_instance_public_ip" {
  description = "Public IP address of the public EC2 instance"
  value       = module.ec2_instances.public_instance_public_ip
}

output "private_instance_private_ip" {
  description = "Private IP address of the private EC2 instance"
  value       = module.ec2_instances.private_instance_private_ip
}

output "nat_gateway_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = module.ec2_instances.key_pair_name
}

output "private_key_file" {
  description = "Path to the generated private key file"
  value       = module.ec2_instances.private_key_file
} 