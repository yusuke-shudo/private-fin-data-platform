resource "snowflake_database" "datawarehouse" {
  name    = "DATAWAREHOUSE_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "datawarehouse_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datawarehouse.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

locals {
  datawarehouse_database_managed_by_targets = [snowflake_database.datawarehouse.fully_qualified_name]
  datawarehouse_schema_managed_by_targets   = [snowflake_schema.datawarehouse_schemachange.fully_qualified_name]
}
