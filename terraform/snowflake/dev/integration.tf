resource "snowflake_storage_integration" "s3_integration" {
  name             = "S3_DATA_LAKE_INTEGRATION"
  comment          = "Storage Integration for S3 Data Lake via S3 Access Point"
  type             = "EXTERNAL_STAGE"
  enabled          = true
  storage_provider = "S3"
  aws_role_arn     = "arn:aws:iam::${var.aws_account_id}:role/private-fin-sf-s3-role"
  allowed_locations = [
    "s3://private-fin-snowflake-ap-${var.aws_account_id}-s3alias/"
  ]
}
