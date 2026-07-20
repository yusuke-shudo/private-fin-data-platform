output "workbench_iam_role_arn" {
  value       = aws_iam_role.workbench_instance_role.arn
  description = "owner-scoped workbench IAM role ARN"
}

output "workbench_iam_role_name" {
  value       = aws_iam_role.workbench_instance_role.name
  description = "owner-scoped workbench IAM role name"
}

output "workbench_instance_profile_name" {
  value       = aws_iam_instance_profile.workbench_instance_profile.name
  description = "owner-scoped workbench instance profile name"
}