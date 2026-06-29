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

