resource "snowflake_database" "datawarehouse" {
  name = "DATAWAREHOUSE_DB"
}

resource "snowflake_schema" "datawarehouse_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datawarehouse.name
  comment  = "Schema for schemachange migration metadata"
}
