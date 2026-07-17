# ==============================================================================
# CI/CD Roles and Users for dbt Data Transformations
# ==============================================================================

resource "snowflake_warehouse" "cicd_data_wh" {
  name            = "cicd_data_wh"
  warehouse_size  = "XSMALL"
  auto_suspend    = 60
  initially_suspended = true
  comment         = "Dedicated warehouse for CI/CD dbt data transformations | ${local.managed_comment}"
}

# Create cicd_data_engineer_role (if using data_source vs resource, adjust as needed)
# Note: This is typically created manually or via bootstrap, but can be managed here
resource "snowflake_role" "cicd_data_engineer_role" {
  name    = "cicd_data_engineer_role"
  comment = "Role for CI/CD dbt data transformations | ${local.managed_comment}"
}

# Grant warehouse usage to cicd_data_engineer_role
resource "snowflake_warehouse_grant" "cicd_data_engineer_wh" {
  warehouse_name = snowflake_warehouse.cicd_data_wh.name
  privilege      = "USAGE"
  roles          = [snowflake_role.cicd_data_engineer_role.name]
}

# Create cicd_data_engineer_user (SERVICE user with OIDC)
resource "snowflake_user" "cicd_data_engineer_user" {
  name                          = "cicd_data_engineer_user"
  type                          = "SERVICE"
  default_role                  = snowflake_role.cicd_data_engineer_role.name
  default_warehouse             = snowflake_warehouse.cicd_data_wh.name
  abort_detached_query          = true
  lock_timeout                  = 10
  statement_timeout_in_seconds  = 1800
  comment                       = "Service user for dbt data transformations via GitHub Actions (repo: private-fin-data-platform) | ${local.managed_comment}"

  # OIDC Authentication - GitHub Actions
  # SUBJECT should be updated to match your environment: dev-data or prd-data
  workload_identity {
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = "repo:yusuke-shudo/private-fin-data-platform:environment:${var.env}-data"
  }
}

# Grant cicd_data_engineer_role to cicd_data_engineer_user
resource "snowflake_role_grant" "cicd_data_engineer_user_role" {
  role_name = snowflake_role.cicd_data_engineer_role.name
  user_name = snowflake_user.cicd_data_engineer_user.name
}

# Tag assignment
resource "snowflake_tag_association" "cicd_data_wh_managed_by" {
  object_identifiers = [snowflake_warehouse.cicd_data_wh.name]
  object_type        = "WAREHOUSE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
