variable "env" {
  type        = string
  description = "実行環境(dev または prd)"
}

variable "sf_user_arn" {
  type        = string
  description = "SnowflakeのStorage Integrationから発行されるAWS用ユーザーARN"
  default     = ""
}

variable "sf_external_id" {
  type        = string
  description = "SnowflakeのStorage Integrationから発行される外部ID"
  default     = ""
}
