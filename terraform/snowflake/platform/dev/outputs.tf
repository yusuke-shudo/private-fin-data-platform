output "si_s3_accesspoint_datalake_iam_user_arn" {
  value       = snowflake_storage_integration_aws.si_s3_accesspoint_datalake.describe_output[0].iam_user_arn
  description = "S3アクセスポイント用SI のSnowflake生成IAMユーザーARN"
}

output "si_s3_accesspoint_datalake_external_id" {
  value       = snowflake_storage_integration_aws.si_s3_accesspoint_datalake.describe_output[0].external_id
  description = "S3アクセスポイント用SI の外部ID"
}

output "si_s3_direct_datalake_iam_user_arn" {
  value       = snowflake_storage_integration_aws.si_s3_direct_datalake.describe_output[0].iam_user_arn
  description = "S3直接バケットアクセス用SI のSnowflake生成IAMユーザーARN"
}

output "si_s3_direct_datalake_external_id" {
  value       = snowflake_storage_integration_aws.si_s3_direct_datalake.describe_output[0].external_id
  description = "S3直接バケットアクセス用SI の外部ID"
}
