data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ubuntu_account_id]

  # filter {
  #   name   = "name"
  #   values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240801,ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20240715"]
  # }
}
