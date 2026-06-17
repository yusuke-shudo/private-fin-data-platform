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


# =========================================================================
# Snowflake連携用 IAM定義
# =========================================================================
resource "aws_iam_role" "sf_role" {
  provider = aws.resource_creation
  name     = "private-fin-sf-s3-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          AWS = var.sf_user_arn != "" ? var.sf_user_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = var.sf_external_id != "" ? {
          StringEquals = {
            "sts:ExternalId" = var.sf_external_id
          }
        } : null
      }
    ]
  })
  tags = {
    Name        = "private-fin-sf-s3-role-${var.env}"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "sf_s3_policy" {
  provider    = aws.resource_creation
  name        = "private-fin-sf-s3-policy-${var.env}"
  description = "Policy for Snowflake to access S3 data lake"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.data_lake.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.data_lake.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sf_role_attach" {
  provider   = aws.resource_creation
  role       = aws_iam_role.sf_role.name
  policy_arn = aws_iam_policy.sf_s3_policy.arn
}
