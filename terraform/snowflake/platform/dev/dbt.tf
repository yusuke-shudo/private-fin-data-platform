# ==============================================================================
# DBT Engineer Role for Snowflake native dbt execution
# ==============================================================================

resource "snowflake_account_role" "dbt_engineer" {
  name    = "DBT_ENGINEER_ROLE"
  comment = "Role for dbt execution on Snowflake native DBT PROJECT | ${local.managed_comment}"
}

resource "snowflake_grant_privileges_to_account_role" "dbt_engineer_execute_task" {
  account_role_name = snowflake_account_role.dbt_engineer.name
  privileges        = ["EXECUTE TASK", "EXECUTE MANAGED TASK"]
  on_account        = true
}
