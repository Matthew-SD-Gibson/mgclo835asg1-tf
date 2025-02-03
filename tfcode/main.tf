provider "aws" {
  region = "us-east-1"  
}


# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

#Create ECR repository
resource "aws_ecr_repository" "mg13rep" {
  name = "${var.prefix}-repository"
}

# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.prefix}-sg"
  description = "Allow inbound SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 Instance in a Public Subnet
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  iam_instance_profile = "LabInstanceProfile"
  security_groups = [aws_security_group.ec2_sg.name]
  user_data = file("${path.module}/docker.sh")

  tags = {
    Name ="${var.prefix}-ec2-instance"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = "mgibson13-asgn1"
  public_key = file ("mgibson13-asgn1.pub")
}
