# the notes are there for you to say in your presentation, we will move somewhere else once we have a recording

variable "inbound_http_port" {
  description = "Port number for inbound HTTP traffic"

  default = 8501
  type    = number

  validation {
    condition     = var.inbound_http_port == 8501
    error_message = "Port is invalid"
  }

  # We keep this constant at 8501, since this is the port used by streamlit which defaults to using the 8501 port

}

variable "inbound_ssh_port" {
  description = "Port number for inbound SSH traffic"

  default = 22
  type    = number

  # No validation needed here since this is an open variable that can be configured to eb anything necessary. For now we default at 22
  # We cannot validate ports anyway until after they are open in terraform, no capability

}

variable "outbound_http_port" {
  description = "Port number for outbound HTTP traffic"

  default = 0
  type    = number

  validation {
    condition     = var.outbound_http_port == 0
    error_message = "Outbound HTTP Port must be 0 (no outbound traffic allowed)"
  }

  # Streamlit apps on EC2 instances will not need any outbound traffic, so this should be set to 0

}

variable "inbound_protocol" {
  description = "Protocol used for inbound traffic"

  default = "tcp"
  type    = string

  validation {
    condition     = contains(var.accepted_protocols, var.inbound_protocol)
    error_message = "Protocol is not accepted"
  }
}

variable "outbound_protocol" {
  description = "Protocol used for outbound traffic"

  default = "-1"
  type    = string

  validation {
    condition     = contains(var.accepted_protocols, var.outbound_protocol)
    error_message = "Protocol is not accepted"
  }
}

variable "instance_type" {
  description = "Instance Type for EC2 Instance"

  default = "t2.micro"
  type    = string

  # Terraform does not validate EC2 instance types because AWS maintains a large and constantly evolving catalog of instance families. Instead of hardcoding an enum, Terraform delegates validation to AWS at apply time. This design avoids drift and ensures compatibility with new instance types without requiring provider updates.

}

variable "iam_instance_profile" {
  description = "Profile for AWS EC2 Instance"

  default = "LabInstanceProfile"
  type    = string

  # No validation needed here. The profile names are defined in aws and are unreachable from here. If it fails, the code will crash loudly during the ssh connect stage

}

variable "key_name" {
  description = "Key Name for SSH Connection"

  default = "vockey"
  type    = string

  # No validation needed here. The key name is defined in aws and is unreachable from here. If it fails, the code will crash loudly during the ssh connect stage

}

variable "public_api" {
  description = "Public API used to find the current user's IP Address"

  default = "https://api.ipify.org"
  type    = string

  validation {
    condition     = can(regex("^https://.*", var.public_api))
    error_message = "API must be a valid HTTPS URL"
  }
}

variable "ubuntu_account_id" {
  description = "The AWS account id for ubuntu"

  default = "099720109477"
  type    = string

  # canonical hosts ubuntus AMIS (Amazon Machine Images). so we need the account id for canonical in order to dynamically retrieve the latest AMI from ubuntu

}
