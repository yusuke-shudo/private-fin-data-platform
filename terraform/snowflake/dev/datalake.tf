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
  name                 = "PAYPAY_BANK_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.paypay_bank.name
  url                  = "s3://${var.aws_s3_ap_alias}/paypay_bank/"
  aws_access_point_arn = "arn:aws:s3:ap-northeast-1:${var.aws_account_id}:accesspoint/private-fin-sf-ap"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_schema" "sbi_securities" {
  name     = "SBI_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage" "sbi_stage" {
  name                 = "SBI_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.sbi_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/sbi/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

resource "snowflake_schema" "monex_securities" {
  name     = "MONEX_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_stage" "monex_stage" {
  name                 = "MONEX_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.monex_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/monex/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment
}

locals {
  datalake_database_managed_by_targets = [snowflake_database.datalake.fully_qualified_name]

  datalake_schema_managed_by_targets = [
    snowflake_schema.schemachange.fully_qualified_name,
    snowflake_schema.common.fully_qualified_name,
    snowflake_schema.paypay_bank.fully_qualified_name,
    snowflake_schema.sbi_securities.fully_qualified_name,
    snowflake_schema.monex_securities.fully_qualified_name,
  ]

  # TEMPORARILY COMMENTED OUT: state cleanup for snowflake_stage -> snowflake_stage_external_s3 migration
  # Uncomment together with snowflake_tag_association.datalake_stage_object_managed_by below after state cleanup run.
  # datalake_stage_object_managed_by_targets = [
  #   snowflake_stage_external_s3.paypay_bank_stage.fully_qualified_name,
  #   snowflake_stage.sbi_stage.fully_qualified_name,
  #   snowflake_stage.monex_stage.fully_qualified_name,
  # ]
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

# TEMPORARILY COMMENTED OUT: state cleanup for snowflake_stage -> snowflake_stage_external_s3 migration
# Uncomment together with datalake_stage_object_managed_by_targets local above after state cleanup run.
# resource "snowflake_tag_association" "datalake_stage_object_managed_by" {
#   object_identifiers = local.datalake_stage_object_managed_by_targets
#   object_type        = "STAGE"
#   tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
#   tag_value          = "terraform"
# }

