resource "time_sleep" "wait_for_aws_propagation" {
  triggers = {
    aws_s3_ap_alias = var.aws_s3_ap_alias
  }
  create_duration = "30s"
}

resource "snowflake_storage_integration_aws" "s3_integration" {
  name                      = "S3_DATA_LAKE_INTEGRATION"
  comment                   = "Storage Integration for S3 Data Lake via S3 Access Point | ${local.managed_comment}"
  enabled                   = true
  storage_provider          = "S3"
  storage_aws_role_arn      = "arn:aws:iam::${var.aws_account_id}:role/private-fin-sf-s3-role"  
  storage_allowed_locations = [
    var.aws_s3_ap_alias != "" ? "s3://${var.aws_s3_ap_alias}/" : "s3://dummy-bootstrap-accesspoint-bucket/"
  ]
  depends_on                = [time_sleep.wait_for_aws_propagation]
}

resource "time_sleep" "integration_output_gate" {
  depends_on      = [snowflake_storage_integration_aws.s3_integration]
  create_duration = "30s"
}
