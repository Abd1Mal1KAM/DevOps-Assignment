data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ubuntu_account_id]

  filter {
    name   = "architecture "
    values = ["i386", "x86_64"]
  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
