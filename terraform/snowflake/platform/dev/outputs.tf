output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].iam_user_arn
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].external_id
}

output "monex_pipe_notification_channel" {
  value       = snowflake_pipe.monex_all_trade_and_cash_history.notification_channel
  description = "このpipeが使うSQSキューのARN。Snowflakeは1アカウント・1リージョンにつきキューを1つ使い回すため、他のpipeを追加しても通常は同じ値になる。AWS側のS3イベント通知（GitHub変数 AWS_S3_SNOWPIPE_QUEUE_ARN）に設定する"
}
