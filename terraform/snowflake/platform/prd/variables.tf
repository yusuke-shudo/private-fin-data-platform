variable "env" {
  type = string
}

variable "sf_organization_name" {
  type = string
}

variable "sf_account_name" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_s3_ap_alias" {
  type        = string
  description = "GitHubのEnvironment変数（AWS_S3_AP_ALIAS）から注入されるAWSアクセスポイントのエイリアス"
  default     = ""
}

variable "managed_repo" {
  type        = string
  description = "Repository name for object lineage metadata"
  default     = "private-fin-data-platform"
}

variable "managed_ref" {
  type        = string
  description = "Source revision for object lineage metadata (commit, tag, or PR)"
  default     = "unknown"
}
