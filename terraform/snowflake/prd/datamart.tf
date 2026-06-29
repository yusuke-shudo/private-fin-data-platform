resource "snowflake_database" "datamart" {
  name    = "DATAMART_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "datamart_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datamart.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}
