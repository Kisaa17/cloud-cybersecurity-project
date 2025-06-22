# Public Security Group
resource "aws_security_group" "public" {
  name        = "${var.project_name}-public-sg"
  description = "Security group for public subnet"
  vpc_id      = var.vpc_id

  # SSH access from your IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  # HTTP access from your IP
  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-public-sg"
    Environment = var.environment
  }
}

# Private Security Group
resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "Security group for private subnet"
  vpc_id      = var.vpc_id

  # SSH access from public subnet only
  ingress {
    description     = "SSH from public subnet"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
  }
  
  # All TCP traffic from public subnet
  ingress {
    description     = "All TCP traffic from public subnet"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.public.id]
  }

  # All outbound traffic (for NAT Gateway access)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-private-sg"
    Environment = var.environment
  }
} 