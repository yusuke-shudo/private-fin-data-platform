output "workbench_warehouse_name" {
  value       = snowflake_warehouse.workbench.name
  description = "owner-scoped workbench warehouse name"
}

output "workbench_role_name" {
  value       = snowflake_account_role.workbench.name
  description = "owner-scoped workbench role name"
}

output "workbench_user_name" {
  value       = snowflake_service_user.workbench.name
  description = "owner-scoped workbench service user name"
}
