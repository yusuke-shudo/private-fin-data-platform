resource "snowflake_database" "datamart" {
  name    = "DATAMART_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "datamart_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datamart.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

locals {
  datamart_database_managed_by_targets = [snowflake_database.datamart.fully_qualified_name]
  datamart_schema_managed_by_targets   = [snowflake_schema.datamart_schemachange.fully_qualified_name]
}
