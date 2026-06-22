output "storage_aws_iam_user_arn" {
  description = "Copy this value to GitHub Variables: SF_USER_ARN"
  value       = [for attr in snowflake_storage_integration_aws.s3_integration.describe_output : attr.value if attr.name == "STORAGE_AWS_IAM_USER_ARN"][0]
}

output "storage_aws_external_id" {
  description = "Copy this value to GitHub Variables: SF_EXTERNAL_ID"
  value       = [for attr in snowflake_storage_integration_aws.s3_integration.describe_output : attr.value if attr.name == "STORAGE_AWS_EXTERNAL_ID"][0]
}
