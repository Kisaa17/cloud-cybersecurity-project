output "public_instance_public_ip" {
  description = "Public IP address of the public EC2 instance"
  value       = aws_instance.public.public_ip
}

output "public_instance_private_ip" {
  description = "Private IP address of the public EC2 instance"
  value       = aws_instance.public.private_ip
}

output "private_instance_private_ip" {
  description = "Private IP address of the private EC2 instance"
  value       = aws_instance.private.private_ip
}

output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

output "public_instance_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public.id
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = aws_key_pair.main.key_name
}

output "private_key_file" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
} 