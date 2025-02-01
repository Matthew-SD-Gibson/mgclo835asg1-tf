provider "aws" {
  region = "us-east-1"  # Choose your desired region
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

resource "aws_ecr_repository" "mg13rep" {
  name = "${var.prefix}-repository"
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.prefix}-ecr-policy"
  description = "Allow EC2 to interact with ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:PutImage"
        ]
        Resource = "${aws_ecr_repository.mg13rep.arn}"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
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
  iam_instance_profile = aws_iam_role.ec2_role.name
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name ="${var.prefix}-ec2-instance"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = "mgibson13-asgn1"
  public_key = file ("mgibson13-asgn1.pub")
}

# ECR Repository
resource "aws_ecr_repository" "mgibson13-asgn1" {
  name = "${var.prefix}-repository"
}
