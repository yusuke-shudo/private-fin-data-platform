output "datalake_bucket_name" {
  value       = aws_s3_bucket.datalake.id
  description = "データレイク用S3バケット名"
}

output "datalake_sf_role_arn" {
  value       = aws_iam_role.datalake_sf.arn
  description = "Snowflake Storage Integration がアサームするIAMロールのARN"
}

output "datalake_s3_access_point_alias" {
  value       = aws_s3_access_point.datalake_sf.alias
  description = "AWSが自動生成したS3アクセスポイントのエイリアス（GitHub変数 AWS_S3_AP_ALIAS に設定する値）"
}

output "snowpipe_sns_topic_arn" {
  value       = aws_sns_topic.snowpipe.arn
  description = "Snowpipe auto-ingest用SNSトピックのARN。SYSTEM$GET_AWS_SNS_IAM_POLICYの引数に使う"
}
