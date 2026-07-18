variable "env" {
  type        = string
  description = "Target environment. Workbench is currently dev only."
  default     = "dev"

  validation {
    condition     = var.env == "dev"
    error_message = "Workbench Terraform root is dev-only."
  }
}

variable "workbench_vpc_cidr" {
  type        = string
  description = "platform VPC CIDR for workbench network"
  default     = "10.120.0.0/16"
}

variable "workbench_az1_name" {
  type        = string
  description = "Logical slot az1 physical AZ name"
  default     = "ap-northeast-1a"
}

variable "workbench_az2_name" {
  type        = string
  description = "Logical slot az2 physical AZ name"
  default     = "ap-northeast-1c"
}

variable "workbench_public_subnet_az1_cidr" {
  type        = string
  description = "Public subnet CIDR for az1"
  default     = "10.120.0.0/24"
}

variable "workbench_private_subnet_az1_cidr" {
  type        = string
  description = "Private subnet CIDR for az1"
  default     = "10.120.10.0/24"
}

variable "workbench_public_subnet_az2_cidr" {
  type        = string
  description = "Public subnet CIDR for az2"
  default     = "10.120.1.0/24"
}

variable "workbench_private_subnet_az2_cidr" {
  type        = string
  description = "Private subnet CIDR for az2"
  default     = "10.120.11.0/24"
}

variable "workbench_nat_mode" {
  type        = string
  description = "NAT instance mode for workbench network"
  default     = "az1_only"

  validation {
    condition     = contains(["none", "az1_only", "az2_only", "az1_az2"], var.workbench_nat_mode)
    error_message = "workbench_nat_mode must be none, az1_only, az2_only, or az1_az2."
  }
}

variable "workbench_nat_instance_type" {
  type        = string
  description = "EC2 instance type for NAT instance"
  default     = "t4g.nano"
}