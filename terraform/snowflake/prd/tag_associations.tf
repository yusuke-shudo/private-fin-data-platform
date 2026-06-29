resource "snowflake_tag_association" "database_managed_by" {
  object_identifiers = concat(
    local.common_database_managed_by_targets,
    local.datalake_database_managed_by_targets,
    local.datamart_database_managed_by_targets,
    local.datawarehouse_database_managed_by_targets,
  )
  object_type = "DATABASE"
  tag_id      = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value   = "terraform"
}

resource "snowflake_tag_association" "schema_managed_by" {
  object_identifiers = concat(
    local.common_schema_managed_by_targets,
    local.datalake_schema_managed_by_targets,
    local.datamart_schema_managed_by_targets,
    local.datawarehouse_schema_managed_by_targets,
  )
  object_type = "SCHEMA"
  tag_id      = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value   = "terraform"
}

resource "snowflake_tag_association" "stage_object_managed_by" {
  object_identifiers = local.datalake_stage_object_managed_by_targets
  object_type        = "STAGE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "integration_object_managed_by" {
  object_identifiers = local.integration_object_managed_by_targets
  object_type        = "INTEGRATION"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}