output "sf_integration_aws_role_arn" {
  value       = aws_iam_role.sf_role.arn
  description = "SnowflakeのStorage Integrationに設定するためのIAMロールARN"
}
