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

variable "sf_ap_alias" {
  type        = string
  description = "GitHubのEnvironment変数（SF_AP_ALIAS）から注入されるAWSアクセスポイントのエイリアス"
  default     = ""
}
