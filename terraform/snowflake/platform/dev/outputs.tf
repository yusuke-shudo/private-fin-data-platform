output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].iam_user_arn
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].external_id
}

output "monex_pipe_notification_channel" {
  value       = snowflake_pipe.monex_all_trade_and_cash_history.notification_channel
  description = "このpipeが使うSnowflake管理のSQSキューのARN。S3→SNS→SQS構成のため配線には使わない。SYSTEM$PIPE_STATUS等の調査用の参考情報"
}
