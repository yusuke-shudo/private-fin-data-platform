output "datalake_bucket_name" {
  value       = aws_s3_bucket.datalake.id
  description = "データレイク用S3バケット名"
}

output "datalake_sf_accesspoint_role_arn" {
  value       = aws_iam_role.datalake_sf_accesspoint.arn
  description = "Snowflake Storage Integration (アクセスポイント経由) がアサームするIAMロールのARN"
}

output "datalake_sf_direct_role_arn" {
  value       = aws_iam_role.datalake_sf_direct.arn
  description = "Snowflake Storage Integration (直接バケット接続) がアサームするIAMロールのARN"
}

output "datalake_s3_access_point_alias" {
  value       = aws_s3_access_point.datalake_sf_accesspoint.alias
  description = "AWSが自動生成したS3アクセスポイントのエイリアス（GitHub変数 AWS_S3_AP_ALIAS に設定する値）"
}
