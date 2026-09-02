output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].iam_user_arn
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].external_id
}

output "snowpipe_queue_arn" {
  value       = snowflake_pipe.monex_all_trade_and_cash_history.notification_channel
  description = "Snowflakeが1アカウント・1リージョンにつき使い回すSnowpipe用SQSキューのARN。特定のpipe専有ではなく、どのpipeのnotification_channelを見ても同じ値になる。AWS側のS3イベント通知（GitHub変数 AWS_S3_SNOWPIPE_QUEUE_ARN）に設定する"
}
