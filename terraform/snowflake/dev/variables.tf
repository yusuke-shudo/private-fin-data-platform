variable "env" {
  type        = string
}

variable "sf_organization_name" {
  type = string
}

variable "sf_account_name" {
  type = string
}

variable "aws_account_id" {
  type        = string
}

variable "aws_s3_ap_alias" {
  type        = string
  description = "GitHubのEnvironment変数（AWS_S3_AP_ALIAS）から注入されるAWSアクセスポイントのエイリアス"
  default     = ""
}
