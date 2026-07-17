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
  name       = "STAGING"
  database   = snowflake_database.datawarehouse.name
  owner      = snowflake_role.cicd_data_engineer_role.name
  comment    = "Silver layer (staging) - dbt staging models | ${local.managed_comment}"
  is_managed = true
}

resource "snowflake_schema" "datawarehouse_core" {
  name       = "CORE"
  database   = snowflake_database.datawarehouse.name
  owner      = snowflake_role.cicd_data_engineer_role.name
  comment    = "Silver layer (core) - dbt fact/dimension models (Iceberg) | ${local.managed_comment}"
  is_managed = true
}

# Grant permissions for cicd_data_engineer_role on DATAWAREHOUSE_DB
resource "snowflake_database_grant" "cicd_data_engineer_datawarehouse_usage" {
  database_name = snowflake_database.datawarehouse.name
  privilege     = "USAGE"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

resource "snowflake_database_grant" "cicd_data_engineer_datawarehouse_create_schema" {
  database_name = snowflake_database.datawarehouse.name
  privilege     = "CREATE SCHEMA"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

# Grant permissions for cicd_data_engineer_role on staging/core schemas
resource "snowflake_schema_grant" "cicd_data_engineer_staging" {
  schema_name = snowflake_schema.datawarehouse_staging.name
  database_name = snowflake_database.datawarehouse.name
  privilege     = "CREATE TABLE"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

resource "snowflake_schema_grant" "cicd_data_engineer_staging_view" {
  schema_name = snowflake_schema.datawarehouse_staging.name
  database_name = snowflake_database.datawarehouse.name
  privilege     = "CREATE VIEW"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

resource "snowflake_schema_grant" "cicd_data_engineer_core" {
  schema_name = snowflake_schema.datawarehouse_core.name
  database_name = snowflake_database.datawarehouse.name
  privilege     = "CREATE TABLE"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

resource "snowflake_schema_grant" "cicd_data_engineer_core_view" {
  schema_name = snowflake_schema.datawarehouse_core.name
  database_name = snowflake_database.datawarehouse.name
  privilege     = "CREATE VIEW"
  roles         = [snowflake_role.cicd_data_engineer_role.name]
}

locals {
  datawarehouse_database_managed_by_targets = [snowflake_database.datawarehouse.fully_qualified_name]
  datawarehouse_schema_managed_by_targets   = [
    snowflake_schema.datawarehouse_schemachange.fully_qualified_name,
    snowflake_schema.datawarehouse_staging.fully_qualified_name,
    snowflake_schema.datawarehouse_core.fully_qualified_name
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
