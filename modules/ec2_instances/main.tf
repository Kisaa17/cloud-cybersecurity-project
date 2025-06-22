# Generate private key
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name        = "${var.project_name}-key-pair"
    Environment = var.environment
  }
}

# Save private key to local file
resource "local_file" "private_key" {
  content  = tls_private_key.main.private_key_pem
  filename = "${path.root}/private_key.pem"

  file_permission = "0400"
}

# Data source for latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for latest Amazon Linux 2 AMI (for private instance)
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Public EC2 Instance (Ubuntu with Kali Linux tools)
resource "aws_instance" "public" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_security_group_id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              
              # Update system packages
              apt update && apt upgrade -y
              
              # Install required packages for Kali Linux tools
              apt install -y wget curl git python3 python3-pip software-properties-common
              
              # Add Kali Linux repositories
              wget -q -O - https://archive.kali.org/archive-key.asc | apt-key add -
              echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | tee /etc/apt/sources.list.d/kali.list
              
              # Update package list with Kali repositories
              apt update
              
              # Install Kali Linux tools
              apt install -y kali-linux-default
              
              # Install additional security and networking tools
              apt install -y nmap netcat-openbsd tcpdump wireshark-cli
              apt install -y openssh-client telnet ftp
              apt install -y vim nano htop iotop
              apt install -y dnsutils dig nslookup
              apt install -y lsof strace ltrace
              apt install -y john hashcat
              apt install -y sqlmap nikto dirb
              apt install -y metasploit-framework
              
              # Install Python-based security tools
              pip3 install requests beautifulsoup4 lxml
              pip3 install paramiko scapy
              pip3 install pwntools
              
              # Create a directory for security tools
              mkdir -p /opt/security-tools
              cd /opt/security-tools
              
              # Download and install additional tools
              # Nmap scripts
              wget https://raw.githubusercontent.com/nmap/nmap/master/scripts/script.db -O /usr/share/nmap/scripts/script.db
              
              # Create a welcome message
              echo "Kali Linux tools installation completed!" > /opt/security-tools/README.txt
              echo "Available tools: nmap, netcat, tcpdump, wireshark, metasploit, sqlmap, nikto, dirb, john, hashcat" >> /opt/security-tools/README.txt
              echo "Python tools: requests, beautifulsoup4, lxml, paramiko, scapy, pwntools" >> /opt/security-tools/README.txt
              echo "Full Kali Linux toolset is available!" >> /opt/security-tools/README.txt
              
              # Set up environment
              echo 'export PATH=$PATH:/opt/security-tools' >> /etc/profile
              echo 'alias ll="ls -la"' >> /etc/profile
              echo 'alias ..="cd .."' >> /etc/profile
              
              # Create a simple web server to show the instance is ready
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Ubuntu Security Tools Server Ready!</h1>" > /var/www/html/index.html
              echo "<p>Kali Linux tools are being installed in the background.</p>" >> /var/www/html/index.html
              echo "<p>Check /opt/security-tools/README.txt for available tools.</p>" >> /var/www/html/index.html
              
              echo "Ubuntu with Kali Linux tools installation completed successfully!"
              EOF

  tags = {
    Name        = "${var.project_name}-public-instance"
    Environment = var.environment
  }
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_security_group_id]
  key_name               = aws_key_pair.main.key_name

/* if you want to use Kali Linux tools uncomment this
  user_data = <<-EOF
              #!/bin/bash
              
              # Update system packages
              yum update -y
              
              # Install required packages for Kali Linux tools
              yum install -y epel-release
              yum install -y wget curl git python3 python3-pip
              
              # Install additional security and networking tools
              yum install -y nmap netcat-openbsd tcpdump wireshark-cli
              yum install -y openssh-clients telnet ftp
              yum install -y vim nano htop iotop
              yum install -y bind-utils dig nslookup
              yum install -y lsof strace ltrace
              yum install -y john hashcat
              yum install -y sqlmap nikto dirb
              yum install -y metasploit-framework
              
              # Install Python-based security tools
              pip3 install requests beautifulsoup4 lxml
              pip3 install paramiko scapy
              pip3 install pwntools
              
              # Create a directory for security tools
              mkdir -p /opt/security-tools
              cd /opt/security-tools
              
              # Download and install additional tools
              # Nmap scripts
              wget https://raw.githubusercontent.com/nmap/nmap/master/scripts/script.db -O /usr/share/nmap/scripts/script.db
              
              # Create a welcome message
              echo "Kali Linux tools installation completed!" > /opt/security-tools/README.txt
              echo "Available tools: nmap, netcat, tcpdump, wireshark, metasploit, sqlmap, nikto, dirb, john, hashcat" >> /opt/security-tools/README.txt
              echo "Python tools: requests, beautifulsoup4, lxml, paramiko, scapy, pwntools" >> /opt/security-tools/README.txt
              
              # Set up environment
              echo 'export PATH=$PATH:/opt/security-tools' >> /etc/profile
              echo 'alias ll="ls -la"' >> /etc/profile
              echo 'alias ..="cd .."' >> /etc/profile
              
              echo "Kali Linux tools installation completed successfully!"
              EOF
*/


  tags = {
    Name        = "${var.project_name}-private-instance"
    Environment = var.environment
  }
}

# Encrypted EBS Volume for Private Instance
resource "aws_ebs_volume" "private_volume" {
  availability_zone = aws_instance.private.availability_zone
  size              = 20
  encrypted         = true

  tags = {
    Name        = "${var.project_name}-private-volume"
    Environment = var.environment
  }
}

# Attach EBS Volume to Private Instance
resource "aws_volume_attachment" "private_volume_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.private_volume.id
  instance_id = aws_instance.private.id
} 