# =========================================================================
# データ配置用 S3バケット定義
# =========================================================================

# 1. バケット本体
resource "aws_s3_bucket" "data_lake" {
  provider      = aws.resource_creation
  bucket        = "private-fin-data-lake-${var.env}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  tags = {
    Name        = "private-fin-data-lake-${var.env}"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

# 2. パブリックアクセスの完全ブロック
resource "aws_s3_bucket_public_access_block" "data_lake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. サーバーサイド暗号化の強制
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. バージョニングの有効化
resource "aws_s3_bucket_versioning" "data_lake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}
