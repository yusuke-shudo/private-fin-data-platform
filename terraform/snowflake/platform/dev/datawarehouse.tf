resource "snowflake_database" "datawarehouse" {
  name    = "DATAWAREHOUSE_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "datawarehouse_schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datawarehouse.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_schema" "datawarehouse_staging" {
  name              = "STAGING"
  database          = snowflake_database.datawarehouse.name
  is_managed_access = true
  comment           = "Schema for standardized and cleaned staging tables | ${local.managed_comment}"
}

resource "snowflake_schema" "datawarehouse_core" {
  name              = "CORE"
  database          = snowflake_database.datawarehouse.name
  is_managed_access = true
  comment           = "Schema for core business entities and dimensions | ${local.managed_comment}"
}

locals {
  datawarehouse_database_managed_by_targets = [snowflake_database.datawarehouse.fully_qualified_name]
  datawarehouse_schema_managed_by_targets = [
    snowflake_schema.datawarehouse_schemachange.fully_qualified_name,
    snowflake_schema.datawarehouse_staging.fully_qualified_name,
    snowflake_schema.datawarehouse_core.fully_qualified_name,
  ]
}

resource "snowflake_tag_association" "datawarehouse_database_managed_by" {
  object_identifiers = local.datawarehouse_database_managed_by_targets
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "datawarehouse_schema_managed_by" {
  object_identifiers = local.datawarehouse_schema_managed_by_targets
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
