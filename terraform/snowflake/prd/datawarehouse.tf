resource "snowflake_database" "datawarehouse" {
  name    = "DATAWAREHOUSE_DB"
  comment = local.managed_comment
}
resource "snowflake_tag_association" "datawarehouse_database_lineage" {
  object_identifiers = [snowflake_database.datawarehouse.fully_qualified_name]
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_schema" "datawarehouse_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datawarehouse.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_tag_association" "datawarehouse_schema_lineage" {
  object_identifiers = [snowflake_schema.datawarehouse_schemachange.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}
