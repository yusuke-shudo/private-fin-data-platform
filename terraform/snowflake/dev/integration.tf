resource "snowflake_storage_integration_aws" "s3_integration" {
  name    = "S3_DATA_LAKE_INTEGRATION"
  comment = "Storage Integration for S3 Data Lake via S3 Access Point"
  enabled = true
  storage_provider = "S3"
  storage_aws_role_arn = "arn:aws:iam::${var.aws_account_id}:role/private-fin-sf-s3-role"  
  storage_allowed_locations = [
    var.sf_ap_alias != "" ? "s3://${var.sf_ap_alias}/" : "s3://dummy-bootstrap-accesspoint-bucket/"
  ]
}
