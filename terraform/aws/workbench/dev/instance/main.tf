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
    key    = "infrastructure/aws/workbench/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "identity" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "infrastructure/aws/workbench/identities/${var.owner}/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_ssm_parameter" "workbench_al2023_arm64_ami" {
  provider = aws.resource_creation
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_instance" "workbench" {
  provider                    = aws.resource_creation
  ami                         = data.aws_ssm_parameter.workbench_al2023_arm64_ami.value
  instance_type               = var.workbench_instance_type
  subnet_id                   = local.workbench_private_subnet_ids[var.az_slot]
  vpc_security_group_ids      = [data.terraform_remote_state.network.outputs.platform_workbench_sg_id]
  iam_instance_profile        = data.terraform_remote_state.identity.outputs.workbench_instance_profile_name
  associate_public_ip_address = false
  user_data_replace_on_change = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    owner                 = var.owner
    sf_organization_name  = var.sf_organization_name
    sf_account_name       = var.sf_account_name
  }))

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.workbench_root_volume_size
  }

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_instance_name
    Role = "workbench-instance"
  })
}