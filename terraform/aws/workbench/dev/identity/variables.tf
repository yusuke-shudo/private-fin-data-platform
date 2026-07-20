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