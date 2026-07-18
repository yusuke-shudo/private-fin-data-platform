locals {
  workbench_common_tags = {
    Project     = "private-fin-data-platform"
    ManagedBy   = "Terraform"
    Environment = var.env
    Scope       = "workbench"
    Owner       = var.owner
    Slot        = var.az_slot
  }

  workbench_instance_name = "platform-workbench-${var.owner}-${var.az_slot}"

  workbench_private_subnet_ids = {
    az1 = data.terraform_remote_state.network.outputs.platform_private_subnet_az1_id
    az2 = data.terraform_remote_state.network.outputs.platform_private_subnet_az2_id
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "infrastructure/aws/workbench/${var.env}/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ssm_parameter" "workbench_al2023_arm64_ami" {
  provider = aws.resource_creation
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-arm64"
}

data "aws_iam_policy_document" "workbench_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workbench_instance_role" {
  provider           = aws.resource_creation
  name               = local.workbench_instance_name
  assume_role_policy = data.aws_iam_policy_document.workbench_assume_role.json

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_instance_name
    Role = "workbench-instance"
  })
}

resource "aws_iam_role_policy_attachment" "workbench_ssm_core" {
  provider   = aws.resource_creation
  role       = aws_iam_role.workbench_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "workbench_instance_profile" {
  provider = aws.resource_creation
  name     = local.workbench_instance_name
  role     = aws_iam_role.workbench_instance_role.name

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_instance_name
    Role = "workbench-instance"
  })
}

resource "aws_instance" "workbench" {
  provider                    = aws.resource_creation
  ami                         = data.aws_ssm_parameter.workbench_al2023_arm64_ami.value
  instance_type               = var.workbench_instance_type
  subnet_id                   = local.workbench_private_subnet_ids[var.az_slot]
  vpc_security_group_ids      = [data.terraform_remote_state.network.outputs.platform_workbench_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.workbench_instance_profile.name
  associate_public_ip_address = false

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.workbench_root_volume_size
  }

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_instance_name
    Role = "workbench-instance"
  })

  depends_on = [aws_iam_role_policy_attachment.workbench_ssm_core]
}