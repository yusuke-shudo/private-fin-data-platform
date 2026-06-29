resource "snowflake_database" "datamart" {
  name    = "DATAMART_DB"
  comment = local.managed_comment
}

resource "snowflake_tag_association" "datamart_database_managed_by" {
  object_identifiers = [snowflake_database.datamart.fully_qualified_name]
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_schema" "datamart_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datamart.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_tag_association" "datamart_schema_managed_by" {
  object_identifiers = [snowflake_schema.datamart_schemachange.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
