terraform {
  required_version = ">= 1.5.0"
}

resource "aws_security_group" "web_app_sg" {
  name        = "Web App Security Group"
  description = "AWS Security Group to provision services for our streamlit web app"

  ingress {
    description = "Incoming HTTP Traffic Configuration"
    from_port   = var.inbound_http_port
    to_port     = var.inbound_http_port
    protocol    = var.inbound_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Incoming SSH Traffic Configuration"
    from_port   = var.inbound_ssh_port
    to_port     = var.inbound_ssh_port
    protocol    = var.inbound_protocol
    cidr_blocks = [local.my_ip_address]
  }

  egress {
    description = "Outgoing Traffic Configuration"
    from_port   = var.outbound_http_port
    to_port     = var.outbound_http_port
    protocol    = var.outbound_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  provider = aws
}

resource "aws_instance" "web_app_instance" {

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  monitoring             = true
  provider               = aws
  ebs_optimized          = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted = true
  }

}
