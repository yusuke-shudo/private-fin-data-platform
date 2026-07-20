output "s3_access_point_alias" {
  value       = aws_s3_access_point.sf_ap.alias
  description = "AWSが自動生成したS3アクセスポイントのエイリアス（Snowflakeの変数に設定する値）"
}
