resource "snowflake_database" "datalake" {
  name = "DATALAKE_DB"
}

resource "snowflake_schema" "schemachange" {
  name     = "SCHEMACHANGE"
  database = snowflake_database.datalake.name
  comment  = "Schema for schemachange migration metadata"
}

resource "snowflake_schema" "paypay_bank" {
  name     = "PAYPAY_BANK"
  database = snowflake_database.datalake.name
}

resource "snowflake_stage" "paypay_bank_stage" {
  name                 = "PAYPAY_BANK_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.paypay_bank.name
  url                  = "s3://${var.aws_s3_ap_alias}/paypay_bank/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
}

resource "snowflake_schema" "sbi_securities" {
  name     = "SBI_SECURITIES"
  database = snowflake_database.datalake.name
}

resource "snowflake_stage" "sbi_stage" {
  name                 = "SBI_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.sbi_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/sbi/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
}

resource "snowflake_schema" "monex_securities" {
  name     = "MONEX_SECURITIES"
  database = snowflake_database.datalake.name
}

resource "snowflake_stage" "monex_stage" {
  name                 = "MONEX_STAGE"
  database             = snowflake_database.datalake.name
  schema               = snowflake_schema.monex_securities.name
  url                  = "s3://${var.aws_s3_ap_alias}/monex/"
  storage_integration  = snowflake_storage_integration_aws.s3_integration.name
}
