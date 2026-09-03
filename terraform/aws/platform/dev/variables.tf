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

variable "snowflake_s3_event_queue_arn" {
  type        = string
  description = "SnowflakeのDirectory Table自動更新用SQSキューARN。DESC STAGEのdirectory_notification_channelから取得し、GitHub変数 AWS_SNOWFLAKE_S3_EVENT_QUEUE_ARN で注入する。未設定の間はS3通知を作成しない"
  default     = ""
}
