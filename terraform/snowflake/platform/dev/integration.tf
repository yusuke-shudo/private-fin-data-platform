# AWS側 terraform/aws/platform/<env>/datalake.tf と命名規則を共有する
locals {
  datalake_bucket_name        = "${var.project_prefix}-${var.env}-datalake"
  datalake_sf_role_arn        = "arn:aws:iam::${var.aws_account_id}:role/${local.datalake_bucket_name}-sf-role"
  datalake_direct_sf_role_arn = "arn:aws:iam::${var.aws_account_id}:role/${local.datalake_bucket_name}-direct-sf-role"
  datalake_sf_ap_arn          = "arn:aws:s3:ap-northeast-1:${var.aws_account_id}:accesspoint/${local.datalake_bucket_name}-sf-ap"
  datalake_direct_s3_url      = "s3://${local.datalake_bucket_name}/"
}

resource "time_sleep" "wait_for_aws_propagation" {
  triggers = {
    aws_s3_ap_alias = var.aws_s3_ap_alias
  }
  create_duration = "30s"
}

resource "snowflake_storage_integration_aws" "s3_integration" {
  name                 = "S3_DATA_LAKE_INTEGRATION"
  comment              = "Storage Integration for S3 Data Lake via S3 Access Point | ${local.managed_comment}"
  enabled              = true
  storage_provider     = "S3"
  storage_aws_role_arn = local.datalake_sf_role_arn
  storage_allowed_locations = [
    var.aws_s3_ap_alias != "" ? "s3://${var.aws_s3_ap_alias}/" : "s3://dummy-bootstrap-accesspoint-bucket/"
  ]
  depends_on = [time_sleep.wait_for_aws_propagation]
}

resource "snowflake_storage_integration_aws" "datalake_direct" {
  name                    = "S3_DATALAKE_DIRECT_INTEGRATION"
  comment                 = "Storage Integration for S3 Datalake direct bucket access | ${local.managed_comment}"
  enabled                 = true
  storage_provider        = "S3"
  storage_aws_role_arn    = local.datalake_direct_sf_role_arn
  storage_aws_external_id = var.sf_external_id
  storage_allowed_locations = [
    "${local.datalake_direct_s3_url}paypay_bank/masters/",
    "${local.datalake_direct_s3_url}orico_credit/masters/",
    "${local.datalake_direct_s3_url}monex_securities/history/"
  ]
  depends_on = [time_sleep.wait_for_aws_propagation]
}

locals {
  integration_object_managed_by_targets = [
    snowflake_storage_integration_aws.s3_integration.fully_qualified_name,
    snowflake_storage_integration_aws.datalake_direct.fully_qualified_name,
  ]
}

resource "time_sleep" "integration_output_gate" {
  depends_on      = [snowflake_storage_integration_aws.s3_integration]
  create_duration = "30s"
}

resource "snowflake_tag_association" "integration_object_managed_by" {
  object_identifiers = local.integration_object_managed_by_targets
  object_type        = "INTEGRATION"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
