resource "snowflake_database" "datamart" {
  name    = "DATAMART_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "datamart_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datamart.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_schema" "datamart_personal_assets" {
  name     = "PERSONAL_ASSETS"
  database = snowflake_database.datamart.name
  comment  = "Schema for personal asset portfolio analytics | ${local.managed_comment}"
}

resource "snowflake_schema" "datamart_investment_performance" {
  name     = "INVESTMENT_PERFORMANCE"
  database = snowflake_database.datamart.name
  comment  = "Schema for investment performance and returns analysis | ${local.managed_comment}"
}

locals {
  datamart_database_managed_by_targets = [snowflake_database.datamart.fully_qualified_name]
  datamart_schema_managed_by_targets = [
    snowflake_schema.datamart_schemachange.fully_qualified_name,
    snowflake_schema.datamart_personal_assets.fully_qualified_name,
    snowflake_schema.datamart_investment_performance.fully_qualified_name,
  ]
}

resource "snowflake_tag_association" "datamart_database_managed_by" {
  object_identifiers = local.datamart_database_managed_by_targets
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "datamart_schema_managed_by" {
  object_identifiers = local.datamart_schema_managed_by_targets
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
