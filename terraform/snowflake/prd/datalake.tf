resource "snowflake_database" "datalake" {
  name    = "DATALAKE_DB"
  comment = local.managed_comment
}

resource "snowflake_tag_association" "datalake_database_managed_by" {
  object_identifiers = [snowflake_database.datalake.fully_qualified_name]
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.database_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_schema" "schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datalake.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_tag_association" "datalake_schemachange_schema_managed_by" {
  object_identifiers = [snowflake_schema.schemachange.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "schemachange"
}

resource "snowflake_schema" "paypay_bank" {
  name     = "PAYPAY_BANK"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "paypay_bank_schema_managed_by" {
  object_identifiers = [snowflake_schema.paypay_bank.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "schemachange"
}

resource "snowflake_stage" "paypay_bank_stage" {
  name                 = "PAYPAY_BANK_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.paypay_bank.name
  url                  = "s3://${var.aws_s3_ap_alias}/paypay_bank/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  lifecycle {
    ignore_changes = [tag]
  }
}

resource "snowflake_tag_association" "paypay_bank_stage_object_managed_by" {
  object_identifiers = [snowflake_stage.paypay_bank_stage.fully_qualified_name]
  object_type        = "STAGE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_schema" "sbi_securities" {
  name     = "SBI_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "sbi_securities_schema_managed_by" {
  object_identifiers = [snowflake_schema.sbi_securities.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "schemachange"
}

resource "snowflake_stage" "sbi_stage" {
  name                 = "SBI_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.sbi_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/sbi/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  lifecycle {
    ignore_changes = [tag]
  }
}

resource "snowflake_tag_association" "sbi_stage_object_managed_by" {
  object_identifiers = [snowflake_stage.sbi_stage.fully_qualified_name]
  object_type        = "STAGE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

resource "snowflake_schema" "monex_securities" {
  name     = "MONEX_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "monex_securities_schema_managed_by" {
  object_identifiers = [snowflake_schema.monex_securities.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.schema_managed_by.fully_qualified_name
  tag_value          = "schemachange"
}

resource "snowflake_stage" "monex_stage" {
  name                 = "MONEX_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.monex_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/monex/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  lifecycle {
    ignore_changes = [tag]
  }
}

resource "snowflake_tag_association" "monex_stage_object_managed_by" {
  object_identifiers = [snowflake_stage.monex_stage.fully_qualified_name]
  object_type        = "STAGE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}

