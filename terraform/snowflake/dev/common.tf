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

