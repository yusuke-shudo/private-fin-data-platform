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
  description = "GitHub actor that owns the workbench identity"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.owner))
    error_message = "owner must contain only letters, numbers, and hyphens."
  }
}

variable "sf_organization_name" {
  type        = string
  description = "Snowflake organization name"
}

variable "sf_account_name" {
  type        = string
  description = "Snowflake account name"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID for IAM role ARN"
}

variable "aws_iam_role_arn" {
  type        = string
  description = "AWS IAM role ARN for Workload Identity"
}
