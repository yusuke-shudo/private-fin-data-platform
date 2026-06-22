output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].iam_user_arn
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration_aws.s3_integration.describe_output[0].external_id
}
