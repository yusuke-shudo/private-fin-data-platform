variable "env" {
  type        = string
  description = "実行環境(dev または prd)"
}

variable "project_prefix" {
  type        = string
  description = "リソース名の接頭辞。tfstateバケットと共通のGitHub変数 PROJECT_PREFIX を注入する"
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

variable "snowpipe_sns_subscriber_principal_arn" {
  type        = string
  description = "SnowflakeのSQSキューがSnowpipe用SNSトピックをSubscribeするために必要なIAMプリンシパルARN。SYSTEM$GET_AWS_SNS_IAM_POLICYの戻り値から取得し、GitHub変数 AWS_SNS_SNOWFLAKE_SUBSCRIBER_ARN 経由で注入する。未取得の間は空文字でよい"
  default     = ""
}
