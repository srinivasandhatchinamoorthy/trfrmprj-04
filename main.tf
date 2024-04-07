#providing the provider details:
provider "aws" {
    profile = "srini92"
  region     = "ap-south-1"
  
}

# VPC Creation:
resource "aws_vpc" "project-4-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "project-4-vpc"
  }
}

# Internet Gateway Creation and Attaching it to the VPC:
resource "aws_internet_gateway" "project-4-igw" {
  vpc_id = aws_vpc.project-4-vpc.id


  tags = {
    Name = "project-4-igw"
  }
}

# Subnet Creation:
resource "aws_subnet" "project-4-public-subnet" {
  vpc_id            = aws_vpc.project-4-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "project-4-public-subnet"
  }
}

# Route Table Creation:
resource "aws_route_table" "project-4-route-table" {
  vpc_id = aws_vpc.project-4-vpc.id
  tags = {
    Name = "project-4-route-table"
  }
}

# Inserting the Route to Internet Gateway:
resource "aws_route" "project-4-routing" {
  route_table_id         = aws_route_table.project-4-route-table.id
  destination_cidr_block = "0.0.0.0/0" # Route all traffic to the Internet Gateway
  gateway_id             = aws_internet_gateway.project-4-igw.id
}

# Subnet Association with the Route Table:
resource "aws_route_table_association" "subnet_asscio" {
  subnet_id      = aws_subnet.project-4-public-subnet.id
  route_table_id = aws_route_table.project-4-route-table.id
}

#To create security_group:
resource "aws_security_group" "project-4-sc" {
  name        = "project-4-sc"
  description = "security group for AWS EC2 instances"
  vpc_id      = aws_vpc.project-4-vpc.id
  # Ingress rules (inbound traffic)
  # Allow SSH (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow HTTP (port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress rules (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "project-4-sc"
  }
}

#To create keypair:
resource "aws_key_pair" "project-4-key" {
  key_name   = "project-4-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# EC2 Instance Creation
resource "aws_instance" "project-4" {
  ami                         = "ami-007020fd9c84e18c7"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.project-4-public-subnet.id
  key_name                    = aws_key_pair.project-4-key.id
  vpc_security_group_ids      = ["${aws_security_group.project-4-sc.id}"]
  user_data                   = file("apache.sh")
  associate_public_ip_address = true
  tags = {
    Name = "project-4"
  }
}

