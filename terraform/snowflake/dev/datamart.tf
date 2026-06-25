resource "snowflake_database" "datamart" {
  name = "DATAMART_DB"
}

resource "snowflake_schema" "datamart_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datamart.name
  comment  = "Schema for schemachange migration metadata"
}
