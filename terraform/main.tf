provider "aws" {
  region = "us-east-2"
}

# Create a key pair in AWS with the unique name
resource "aws_key_pair" "deployer1" {
  key_name   = "unique-deployer-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "amazon_linux" {
  ami           = "ami-033fabdd332044f06"  # Amazon Linux 2 AMI for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer1.key_name
  tags = {
    Name = "c8.local"
  }
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-09040d770ffe2224f"  # Ubuntu 21.04 AMI for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer1.key_name
  tags = {
    Name = "u21.local"
  }
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
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


