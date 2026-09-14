# ==============================================================================
# DBT Engineer Role for Snowflake native dbt execution
# ==============================================================================

resource "snowflake_role" "dbt_engineer" {
  name    = "DBT_ENGINEER_ROLE"
  comment = "Role for dbt execution on Snowflake native DBT PROJECT | ${local.managed_comment}"
}
