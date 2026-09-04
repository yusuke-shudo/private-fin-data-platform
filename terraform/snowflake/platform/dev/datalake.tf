resource "snowflake_database" "datalake" {
  name    = "DATALAKE_DB"
  comment = local.managed_comment
}

resource "snowflake_schema" "schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datalake.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_schema" "common" {
  name     = "COMMON"
  database = snowflake_database.datalake.name
  comment  = "Schema for shared datalake procedures and file formats | ${local.managed_comment}"
}

resource "snowflake_schema" "paypay_bank" {
  name     = "PAYPAY_BANK"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage_external_s3" "paypay_bank_stage" {
  name                 = "STAGE_PAYPAY_BANK"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.paypay_bank.name
  url                  = "s3://${var.aws_s3_ap_alias}/paypay_bank/"
  aws_access_point_arn = local.datalake_sf_ap_arn
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_stage_external_s3" "paypay_bank_masters_direct_dir_stage" {
  name                = "STAGE_PAYPAY_BANK_MASTERS_DIRECT_DIR"
  database            = snowflake_database.datalake.name
  schema              = snowflake_schema.paypay_bank.name
  url                 = "${local.datalake_direct_s3_url}paypay_bank/masters/"
  storage_integration = snowflake_storage_integration_aws.datalake_direct.name
  comment             = local.managed_comment
  directory {
    enable            = true
    auto_refresh      = "true"
    refresh_on_create = "true"
  }
}

resource "snowflake_schema" "orico_credit" {
  name     = "ORICO_CREDIT"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage_external_s3" "orico_credit_stage" {
  name                 = "STAGE_ORICO_CREDIT"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.orico_credit.name
  url                  = "s3://${var.aws_s3_ap_alias}/orico_credit/"
  aws_access_point_arn = local.datalake_sf_ap_arn
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_stage_external_s3" "orico_credit_masters_direct_dir_stage" {
  name                = "STAGE_ORICO_CREDIT_MASTERS_DIRECT_DIR"
  database            = snowflake_database.datalake.name
  schema              = snowflake_schema.orico_credit.name
  url                 = "${local.datalake_direct_s3_url}orico_credit/masters/"
  storage_integration = snowflake_storage_integration_aws.datalake_direct.name
  comment             = local.managed_comment
  directory {
    enable            = true
    auto_refresh      = "true"
    refresh_on_create = "true"
  }
}

resource "snowflake_schema" "sbi_securities" {
  name     = "SBI_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage_external_s3" "sbi_stage" {
  name                 = "STAGE_SBI_SECURITIES"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.sbi_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/sbi_securities/"
  aws_access_point_arn = local.datalake_sf_ap_arn
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_schema" "monex_securities" {
  name     = "MONEX_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage_external_s3" "monex_stage" {
  name                 = "STAGE_MONEX_SECURITIES"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.monex_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/monex_securities/"
  aws_access_point_arn = local.datalake_sf_ap_arn
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_stage_external_s3" "monex_history_direct_stage" {
  name                = "STAGE_MONEX_SECURITIES_HISTORY_DIRECT"
  database            = snowflake_database.datalake.name
  schema              = snowflake_schema.monex_securities.name
  url                 = "${local.datalake_direct_s3_url}monex_securities/history/"
  storage_integration = snowflake_storage_integration_aws.datalake_direct.name
  comment             = local.managed_comment
}

locals {
  datalake_database_managed_by_targets = [snowflake_database.datalake.fully_qualified_name]

  datalake_schema_managed_by_targets = [
    snowflake_schema.schemachange.fully_qualified_name,
    snowflake_schema.common.fully_qualified_name,
    snowflake_schema.paypay_bank.fully_qualified_name,
    snowflake_schema.orico_credit.fully_qualified_name,
    snowflake_schema.sbi_securities.fully_qualified_name,
    snowflake_schema.monex_securities.fully_qualified_name,
  ]

  datalake_stage_object_managed_by_targets = [
    snowflake_stage_external_s3.paypay_bank_stage.fully_qualified_name,
    snowflake_stage_external_s3.paypay_bank_masters_direct_dir_stage.fully_qualified_name,
    snowflake_stage_external_s3.orico_credit_stage.fully_qualified_name,
    snowflake_stage_external_s3.orico_credit_masters_direct_dir_stage.fully_qualified_name,
    snowflake_stage_external_s3.sbi_stage.fully_qualified_name,
    snowflake_stage_external_s3.monex_stage.fully_qualified_name,
    snowflake_stage_external_s3.monex_history_direct_stage.fully_qualified_name,
  ]
}

resource "snowflake_tag_association" "datalake_database_managed_by" {
  object_identifiers = local.datalake_database_managed_by_targets
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "datalake_schema_managed_by" {
  object_identifiers = local.datalake_schema_managed_by_targets
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_tag_association" "datalake_stage_object_managed_by" {
  object_identifiers = local.datalake_stage_object_managed_by_targets
  object_type        = "STAGE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

# ==============================================================================
# Grants for cicd_data_engineer_role (dbt operations - read source data)
# ==============================================================================

# DATABASE USAGE
resource "snowflake_grant_privileges_to_account_role" "datalake_cicd_database" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.datalake.name
  }
}

# USAGE on all current schemas in the database
resource "snowflake_grant_privileges_to_account_role" "datalake_cicd_all_schemas_usage" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_schema {
    all_schemas_in_database = snowflake_database.datalake.name
  }
}

# USAGE on future schemas in the database
resource "snowflake_grant_privileges_to_account_role" "datalake_cicd_future_schemas_usage" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["USAGE"]
  on_schema {
    future_schemas_in_database = snowflake_database.datalake.name
  }
}

# SELECT on all current tables in the database
resource "snowflake_grant_privileges_to_account_role" "datalake_cicd_select_tables" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.datalake.name
    }
  }
}

# SELECT on future tables in the database
resource "snowflake_grant_privileges_to_account_role" "datalake_cicd_select_future_tables" {
  account_role_name = "CICD_DATA_ENGINEER_ROLE"
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.datalake.name
    }
  }
}
