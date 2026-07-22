variable "env" {
  type        = string
  description = "Target environment. Workbench is currently dev only."
  default     = "dev"

  validation {
    condition     = var.env == "dev"
    error_message = "Workbench Terraform root is dev-only."
  }
}

variable "owner" {
  type        = string
  description = "GitHub actor that owns the workbench instance"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.owner))
    error_message = "owner must contain only letters, numbers, and hyphens."
  }
}

variable "az_slot" {
  type        = string
  description = "Logical AZ slot where the workbench instance is created"
  default     = "az1"

  validation {
    condition     = contains(["az1", "az2"], var.az_slot)
    error_message = "az_slot must be az1 or az2."
  }
}

variable "workbench_instance_type" {
  type        = string
  description = "EC2 instance type for developer workbench instance. NOTE: t4g.micro is insufficient for VS Code tunnel (OOM). Use t4g.small (2GB) or larger."
  default     = "t4g.small"
}

variable "workbench_root_volume_size" {
  type        = number
  description = "Root volume size in GiB for developer workbench instance"
  default     = 30
}

variable "tfstate_bucket" {
  type        = string
  description = "S3 bucket or access point ARN used for Terraform remote state"
}

variable "sf_organization_name" {
  type        = string
  description = "Snowflake organization name"
}

variable "sf_account_name" {
  type        = string
  description = "Snowflake account name for dev environment"
}