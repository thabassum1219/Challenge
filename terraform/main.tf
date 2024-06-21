provider "aws" {
  region = "us-east-2"
}

# Generate a new SSH key pair using TLS provider
resource "tls_private_key" "amazon_linux_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "ubuntu_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pairs for each instance
resource "aws_key_pair" "amazon_linux_keypair" {
  key_name   = "amazon-linux-keypair-${random_string.suffix.result}"
  public_key = tls_private_key.amazon_linux_key.public_key_openssh
}

resource "aws_key_pair" "ubuntu_keypair" {
  key_name   = "ubuntu-keypair-${random_string.suffix.result}"
  public_key = tls_private_key.ubuntu_key.public_key_openssh
}

resource "aws_instance" "amazon_linux" {
  ami           = "ami-033fabdd332044f06"  # Amazon Linux 2 AMI for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.amazon_linux_keypair.key_name
  tags = {
    Name = "c8.local"
  }
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-09040d770ffe2224f"  # Ubuntu 21.04 AMI for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ubuntu_keypair.key_name
  tags = {
    Name = "u21.local"
  }
}

output "private_key_pem_amazon_linux" {
  value     = tls_private_key.amazon_linux_key.private_key_pem
  sensitive = true
}

output "private_key_pem_ubuntu" {
  value     = tls_private_key.ubuntu_key.private_key_pem
  sensitive = true
}

output "inventory" {
  value = <<EOF
[frontend]
c8.local ansible_host=${aws_instance.amazon_linux.public_ip}

[backend]
u21.local ansible_host=${aws_instance.ubuntu.public_ip}
EOF
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

