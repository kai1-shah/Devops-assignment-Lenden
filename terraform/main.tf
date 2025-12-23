terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------------
# INTENTIONALLY INSECURE SECURITY GROUP
# -------------------------------
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Security group with intentional vulnerability"

  ingress {
    description = "SSH open to the world (INTENTIONAL VULNERABILITY)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
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

# -------------------------------
# EC2 INSTANCE
# -------------------------------
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.insecure_sg.id]

  tags = {
    Name = "DevSecOps-Insecure-Instance"
  }
}
