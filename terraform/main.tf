resource "aws_security_group" "secure_sg" {
  name        = "secure-web-sg"
  description = "Security group with restricted access"

  # INGRESS RULE - FIXED: Restrict to specific IP instead of 0.0.0.0/0
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP or specific range
    description = "Allow HTTP from specific IP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP or specific range
    description = "Allow HTTPS from specific IP"
  }

  # INGRESS RULE - FIXED: Restrict SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP
    description = "Allow SSH from specific IP"
  }

  # EGRESS RULE - FIXED: Restrict to necessary destinations only
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for package updates"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound for package updates"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow DNS queries"
  }

  tags = {
    Name = "secure-web-sg"
  }
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.secure_sg.id]

  # FIXED: Enable IMDS token requirement (HIGH severity fix)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # FIXED: Enable encryption for root block device (HIGH severity fix)
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
