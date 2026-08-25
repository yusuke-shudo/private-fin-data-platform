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
  name                = "STAGING"
  database            = snowflake_database.datawarehouse.name
  with_managed_access = true
  comment             = "Schema for standardized and cleaned staging tables | ${local.managed_comment}"
}

resource "snowflake_schema" "datawarehouse_reference" {
  name                = "REFERENCE"
  database            = snowflake_database.datawarehouse.name
  with_managed_access = true
  comment             = "Schema for dbt-managed reference data | ${local.managed_comment}"
}

resource "snowflake_schema" "datawarehouse_core" {
  name                = "CORE"
  database            = snowflake_database.datawarehouse.name
  with_managed_access = true
  comment             = "Schema for core business entities and dimensions | ${local.managed_comment}"
}

locals {
  datawarehouse_database_managed_by_targets = [snowflake_database.datawarehouse.fully_qualified_name]
  datawarehouse_schema_managed_by_targets = [
    snowflake_schema.datawarehouse_schemachange.fully_qualified_name,
    snowflake_schema.datawarehouse_staging.fully_qualified_name,
    snowflake_schema.datawarehouse_reference.fully_qualified_name,
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

# ==============================================================================
# Grants for cicd_data_engineer_role (dbt operations)
# ==============================================================================

# DATABASE USAGE
resource "snowflake_grant_privileges_to_account_role" "datawarehouse_cicd_database" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.datawarehouse.name
  }
}

# STAGING schema
resource "snowflake_grant_privileges_to_account_role" "datawarehouse_staging_usage" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_staging.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_staging_create_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_staging.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_staging_create_view" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE VIEW"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_staging.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_staging_create_dynamic_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE DYNAMIC TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_staging.name}"
  }
}

# REFERENCE schema
resource "snowflake_grant_privileges_to_account_role" "datawarehouse_reference_usage" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_reference.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_reference_create_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_reference.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_reference_create_view" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE VIEW"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_reference.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_reference_create_dynamic_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE DYNAMIC TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_reference.name}"
  }
}

# CORE schema
resource "snowflake_grant_privileges_to_account_role" "datawarehouse_core_usage" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_core.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_core_create_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_core.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_core_create_view" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE VIEW"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_core.name}"
  }
}

resource "snowflake_grant_privileges_to_account_role" "datawarehouse_core_create_dynamic_table" {
  account_role_name = "cicd_data_engineer_role"
  privileges        = ["CREATE DYNAMIC TABLE"]
  on_schema {
    schema_name = "${snowflake_database.datawarehouse.name}.${snowflake_schema.datawarehouse_core.name}"
  }
}
