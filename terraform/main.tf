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

resource "aws_security_group" "secure_sg" {
  name        = "secure-web-sg"
  description = "Security group with restricted access"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    ipv6_cidr_blocks = ["2405:201:37:c0af:21ba:1778:35f:dbef/128", "2405:201:37:c0af:2cd6:b699:71f8:6687/128"]
    cidr_blocks      = ["192.168.29.18/32"]
    description      = "Allow HTTP from your IPs"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    ipv6_cidr_blocks = ["2405:201:37:c0af:21ba:1778:35f:dbef/128", "2405:201:37:c0af:2cd6:b699:71f8:6687/128"]
    cidr_blocks      = ["192.168.29.18/32"]
    description      = "Allow HTTPS from your IPs"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    ipv6_cidr_blocks = ["2405:201:37:c0af:21ba:1778:35f:dbef/128", "2405:201:37:c0af:2cd6:b699:71f8:6687/128"]
    cidr_blocks      = ["192.168.29.18/32"]
    description      = "Allow SSH from your IPs"
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow HTTPS outbound for package updates"
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow HTTP outbound for package updates"
  }

  egress {
    from_port       = 53
    to_port         = 53
    protocol        = "udp"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow DNS queries"
  }

  tags = {
    Name = "secure-web-sg"
  }
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.secure_sg.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "DevSecOps-Root-Volume"
    }
  }

  tags = {
    Name = "DevSecOps-Secure-Instance"
  }
}
