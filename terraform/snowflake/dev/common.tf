resource "snowflake_database" "common" {
  name    = "COMMON_DB"
  comment = local.managed_comment
}

resource "snowflake_tag_association" "common_database_lineage" {
  object_identifiers = [snowflake_database.common.fully_qualified_name]
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_schema" "governance" {
  name     = "GOVERNANCE"
  database = snowflake_database.common.name
  comment  = "Governance metadata and control objects | ${local.managed_comment}"
}

resource "snowflake_tag_association" "governance_schema_lineage" {
  object_identifiers = [snowflake_schema.governance.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_tag" "managed_lineage" {
  name     = "MANAGED_LINEAGE"
  database = snowflake_database.common.name
  schema   = snowflake_schema.governance.name
  comment  = "Managed object lineage metadata"
}

resource "snowflake_schema" "utils" {
  name     = "UTILS"
  database = snowflake_database.common.name
  comment  = "Shared utility functions | ${local.managed_comment}"
}

resource "snowflake_tag_association" "utils_schema_lineage" {
  object_identifiers = [snowflake_schema.utils.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}