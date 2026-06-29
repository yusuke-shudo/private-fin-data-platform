resource "snowflake_database" "datalake" {
  name    = "DATALAKE_DB"
  comment = local.managed_comment
}

resource "snowflake_tag_association" "datalake_database_lineage" {
  object_identifiers = [snowflake_database.datalake.fully_qualified_name]
  object_type        = "DATABASE"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_schema" "schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datalake.name
  comment  = "Schema for schemachange migration metadata | ${local.managed_comment}"
}

resource "snowflake_tag_association" "schemachange_schema_lineage" {
  object_identifiers = [snowflake_schema.schemachange.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_schema" "paypay_bank" {
  name     = "PAYPAY_BANK"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "paypay_bank_schema_lineage" {
  object_identifiers = [snowflake_schema.paypay_bank.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_stage" "paypay_bank_stage" {
  name                 = "PAYPAY_BANK_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.paypay_bank.name
  url                  = "s3://${var.aws_s3_ap_alias}/paypay_bank/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  tag {
    name     = snowflake_tag.managed_lineage.name
    database = snowflake_tag.managed_lineage.database
    schema   = snowflake_tag.managed_lineage.schema
    value    = local.managed_comment
  }
}

resource "snowflake_schema" "sbi_securities" {
  name     = "SBI_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "sbi_securities_schema_lineage" {
  object_identifiers = [snowflake_schema.sbi_securities.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_stage" "sbi_stage" {
  name                 = "SBI_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.sbi_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/sbi/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  tag {
    name     = snowflake_tag.managed_lineage.name
    database = snowflake_tag.managed_lineage.database
    schema   = snowflake_tag.managed_lineage.schema
    value    = local.managed_comment
  }
}

resource "snowflake_schema" "monex_securities" {
  name     = "MONEX_SECURITIES"
  database = snowflake_database.datalake.name
  comment  = local.managed_comment
}

resource "snowflake_tag_association" "monex_securities_schema_lineage" {
  object_identifiers = [snowflake_schema.monex_securities.fully_qualified_name]
  object_type        = "SCHEMA"
  tag_id             = snowflake_tag.managed_lineage.fully_qualified_name
  tag_value          = local.managed_comment
}

resource "snowflake_stage" "monex_stage" {
  name                 = "MONEX_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.monex_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/monex/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
  comment              = local.managed_comment

  tag {
    name     = snowflake_tag.managed_lineage.name
    database = snowflake_tag.managed_lineage.database
    schema   = snowflake_tag.managed_lineage.schema
    value    = local.managed_comment
  }
}

