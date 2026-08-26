resource "snowflake_database" "common" {
  name    = "COMMON_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "governance" {
  name     = "GOVERNANCE"
  database = snowflake_database.common.name
  comment  = "Governance metadata and control objects | ${local.managed_comment}"
}

resource "snowflake_tag" "database_managed_by" {
  name     = "DATABASE_MANAGED_BY"
  database = snowflake_database.common.name
  schema   = snowflake_schema.governance.name
  comment  = "Database management owner"
}

resource "snowflake_tag" "schema_managed_by" {
  name     = "SCHEMA_MANAGED_BY"
  database = snowflake_database.common.name
  schema   = snowflake_schema.governance.name
  comment  = "Schema management owner"
}

resource "snowflake_tag" "object_managed_by" {
  name     = "OBJECT_MANAGED_BY"
  database = snowflake_database.common.name
  schema   = snowflake_schema.governance.name
  comment  = "Object management owner"
}

resource "snowflake_schema" "utils" {
  name     = "UTILS"
  database = snowflake_database.common.name
  comment  = "Shared utility functions | ${local.managed_comment}"
}

locals {
  common_database_managed_by_targets = [snowflake_database.common.fully_qualified_name]

  common_schema_managed_by_targets = [
    snowflake_schema.governance.fully_qualified_name,
    snowflake_schema.utils.fully_qualified_name,
  ]
}

resource "snowflake_tag_association" "common_database_managed_by" {
  object_identifiers = local.common_database_managed_by_targets
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "common_schema_managed_by" {
  object_identifiers = local.common_schema_managed_by_targets
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

# ==============================================================================
# Grants for cicd_data_engineer_role (dbt operations - tags & utilities)
# ==============================================================================

# DATABASE USAGE
resource "snowflake_grant_privileges_to_account_role" "common_cicd_database" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.common.name
  }
}

# GOVERNANCE schema (tags used by dbt_constraints)
resource "snowflake_grant_privileges_to_account_role" "common_cicd_governance_usage" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.common.name}.${snowflake_schema.governance.name}"
  }
}

# Tag privileges
resource "snowflake_grant_privileges_to_account_role" "common_cicd_tags_apply" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["APPLY"]
  on_schema_object {
    object_type = "TAG"
    object_name = snowflake_tag.database_managed_by.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "common_cicd_schema_managed_by_tag_apply" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["APPLY"]
  on_schema_object {
    object_type = "TAG"
    object_name = snowflake_tag.schema_managed_by.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "common_cicd_object_managed_by_tag_apply" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["APPLY"]
  on_schema_object {
    object_type = "TAG"
    object_name = snowflake_tag.object_managed_by.fully_qualified_name
  }
}

# UTILS schema (shared utility functions)
resource "snowflake_grant_privileges_to_account_role" "common_cicd_utils_usage" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.common.name}.${snowflake_schema.utils.name}"
  }
}

