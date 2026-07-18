# =========================================================================
# workbench network foundation (dev only)
# =========================================================================

locals {
  workbench_common_tags = {
    Project     = "private-fin-data-platform"
    ManagedBy   = "Terraform"
    Environment = var.env
    Scope       = "workbench"
  }

  workbench_nat_enabled_az_slots = {
    none     = []
    az1_only = ["az1"]
    az2_only = ["az2"]
    az1_az2  = ["az1", "az2"]
  }[var.workbench_nat_mode]

  workbench_private_subnet_cidrs = [
    var.workbench_private_subnet_az1_cidr,
    var.workbench_private_subnet_az2_cidr
  ]

  workbench_public_subnet_ids = {
    az1 = aws_subnet.platform_public_subnet_az1.id
    az2 = aws_subnet.platform_public_subnet_az2.id
  }

  workbench_private_route_table_ids = {
    az1 = aws_route_table.platform_private_rt_az1.id
    az2 = aws_route_table.platform_private_rt_az2.id
  }
}

resource "aws_vpc" "platform_vpc" {
  provider             = aws.resource_creation
  cidr_block           = var.workbench_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.workbench_common_tags, {
    Name = "platform-vpc"
  })
}

resource "aws_internet_gateway" "platform_igw" {
  provider = aws.resource_creation
  vpc_id   = aws_vpc.platform_vpc.id

  tags = merge(local.workbench_common_tags, {
    Name = "platform-igw"
  })
}

resource "aws_subnet" "platform_public_subnet_az1" {
  provider                = aws.resource_creation
  vpc_id                  = aws_vpc.platform_vpc.id
  cidr_block              = var.workbench_public_subnet_az1_cidr
  availability_zone       = var.workbench_az1_name
  map_public_ip_on_launch = true

  tags = merge(local.workbench_common_tags, {
    Name = "platform-public-subnet-az1"
    Slot = "az1"
    Tier = "public"
  })
}

resource "aws_subnet" "platform_private_subnet_az1" {
  provider                = aws.resource_creation
  vpc_id                  = aws_vpc.platform_vpc.id
  cidr_block              = var.workbench_private_subnet_az1_cidr
  availability_zone       = var.workbench_az1_name
  map_public_ip_on_launch = false

  tags = merge(local.workbench_common_tags, {
    Name = "platform-private-subnet-az1"
    Slot = "az1"
    Tier = "private"
  })
}

resource "aws_subnet" "platform_public_subnet_az2" {
  provider                = aws.resource_creation
  vpc_id                  = aws_vpc.platform_vpc.id
  cidr_block              = var.workbench_public_subnet_az2_cidr
  availability_zone       = var.workbench_az2_name
  map_public_ip_on_launch = true

  tags = merge(local.workbench_common_tags, {
    Name = "platform-public-subnet-az2"
    Slot = "az2"
    Tier = "public"
  })
}

resource "aws_subnet" "platform_private_subnet_az2" {
  provider                = aws.resource_creation
  vpc_id                  = aws_vpc.platform_vpc.id
  cidr_block              = var.workbench_private_subnet_az2_cidr
  availability_zone       = var.workbench_az2_name
  map_public_ip_on_launch = false

  tags = merge(local.workbench_common_tags, {
    Name = "platform-private-subnet-az2"
    Slot = "az2"
    Tier = "private"
  })
}

resource "aws_route_table" "platform_public_rt" {
  provider = aws.resource_creation
  vpc_id   = aws_vpc.platform_vpc.id

  tags = merge(local.workbench_common_tags, {
    Name = "platform-public-rt"
  })
}

resource "aws_route" "platform_public_default_route" {
  provider               = aws.resource_creation
  route_table_id         = aws_route_table.platform_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.platform_igw.id
}

resource "aws_route_table_association" "platform_public_rt_assoc_az1" {
  provider       = aws.resource_creation
  subnet_id      = aws_subnet.platform_public_subnet_az1.id
  route_table_id = aws_route_table.platform_public_rt.id
}

resource "aws_route_table_association" "platform_public_rt_assoc_az2" {
  provider       = aws.resource_creation
  subnet_id      = aws_subnet.platform_public_subnet_az2.id
  route_table_id = aws_route_table.platform_public_rt.id
}

resource "aws_security_group" "platform_nat_sg" {
  provider    = aws.resource_creation
  name        = "platform-nat-sg"
  description = "Security group for platform NAT instance"
  vpc_id      = aws_vpc.platform_vpc.id

  ingress {
    description = "Allow HTTP from private subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.workbench_private_subnet_cidrs
  }

  ingress {
    description = "Allow HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.workbench_private_subnet_cidrs
  }

  egress {
    description = "Allow HTTP to internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.workbench_common_tags, {
    Name = "platform-nat-sg"
  })
}

resource "aws_security_group" "platform_workbench_sg" {
  provider    = aws.resource_creation
  name        = "platform-workbench-sg"
  description = "Security group for developer workbench instances"
  vpc_id      = aws_vpc.platform_vpc.id

  egress {
    description = "Allow HTTP to internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.workbench_common_tags, {
    Name = "platform-workbench-sg"
  })
}

data "aws_ssm_parameter" "nat_al2023_arm64_ami" {
  provider = aws.resource_creation
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-arm64"
}

resource "aws_instance" "platform_nat_instance" {
  for_each                    = toset(local.workbench_nat_enabled_az_slots)
  provider                    = aws.resource_creation
  ami                         = data.aws_ssm_parameter.nat_al2023_arm64_ami.value
  instance_type               = var.workbench_nat_instance_type
  subnet_id                   = local.workbench_public_subnet_ids[each.key]
  vpc_security_group_ids      = [aws_security_group.platform_nat_sg.id]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOT
              #!/bin/bash
              set -eux
              dnf -y update
              dnf -y install iptables-services
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward = 1" >/etc/sysctl.d/99-nat.conf
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              service iptables save
              systemctl enable iptables
              EOT

  tags = merge(local.workbench_common_tags, {
    Name = "platform-nat-instance-${each.key}"
    Role = "nat"
    Slot = each.key
  })
}

resource "aws_eip" "platform_nat_eip" {
  for_each = toset(["az1", "az2"])
  provider = aws.resource_creation
  domain   = "vpc"

  tags = merge(local.workbench_common_tags, {
    Name = "platform-nat-eip-${each.key}"
    Slot = each.key
  })
}

resource "aws_eip_association" "platform_nat_eip_assoc" {
  for_each      = aws_instance.platform_nat_instance
  provider      = aws.resource_creation
  allocation_id = aws_eip.platform_nat_eip[each.key].id
  instance_id   = each.value.id
}

resource "aws_route_table" "platform_private_rt_az1" {
  provider = aws.resource_creation
  vpc_id   = aws_vpc.platform_vpc.id

  tags = merge(local.workbench_common_tags, {
    Name = "platform-private-rt-az1"
    Slot = "az1"
  })
}

resource "aws_route_table" "platform_private_rt_az2" {
  provider = aws.resource_creation
  vpc_id   = aws_vpc.platform_vpc.id

  tags = merge(local.workbench_common_tags, {
    Name = "platform-private-rt-az2"
    Slot = "az2"
  })
}

resource "aws_route" "platform_private_default_route" {
  for_each               = aws_instance.platform_nat_instance
  provider               = aws.resource_creation
  route_table_id         = local.workbench_private_route_table_ids[each.key]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = each.value.primary_network_interface_id
}

resource "aws_route_table_association" "platform_private_rt_assoc_az1" {
  provider       = aws.resource_creation
  subnet_id      = aws_subnet.platform_private_subnet_az1.id
  route_table_id = aws_route_table.platform_private_rt_az1.id
}

resource "aws_route_table_association" "platform_private_rt_assoc_az2" {
  provider       = aws.resource_creation
  subnet_id      = aws_subnet.platform_private_subnet_az2.id
  route_table_id = aws_route_table.platform_private_rt_az2.id
}