# =========================================================================
# データ配置用 S3バケット本体と基本設定
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
  provider                = aws.resource_creation
  bucket                  = aws_s3_bucket.data_lake.id
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
  provider           = aws.resource_creation
  name               = "private-fin-sf-s3-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      merge(
        {
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = {
            AWS = var.sf_user_arn != "" ? var.sf_user_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
        },
        var.sf_external_id != "" ? {
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.sf_external_id
            }
          }
        } : {}
      )
    ]
  })
  tags = {
    Name        = "private-fin-sf-s3-role"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_iam_role.sf_role]
  create_duration = "30s"
}

# =========================================================================
# 外部システム（Snowflake）専用のアクセスポイント
# =========================================================================
resource "aws_s3_access_point" "sf_ap" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.data_lake.id
  name     = "private-fin-sf-ap"
  depends_on = [time_sleep.wait_30_seconds]
  policy   = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSnowflakeAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.sf_role.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:ap-northeast-1:${data.aws_caller_identity.current.account_id}:accesspoint/private-fin-sf-ap",
          "arn:aws:s3:ap-northeast-1:${data.aws_caller_identity.current.account_id}:accesspoint/private-fin-sf-ap/object/*"
        ]
      },
      {
        Sid       = "DenyAllDataOpsExceptSnowflake"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource  = "arn:aws:s3:ap-northeast-1:${data.aws_caller_identity.current.account_id}:accesspoint/private-fin-sf-ap/object/*"
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = [
              aws_iam_role.sf_role.arn
            ]
          }
        }
      }
    ]
  })
}

# =========================================================================
# バケットポリシー
# =========================================================================
resource "aws_s3_bucket_policy" "data_lake_policy" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.data_lake.id
  policy   = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyDirectAccessExceptAccessPointAndBootstrap"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "s3:DataAccessPointArn" = aws_s3_access_point.sf_ap.arn
          }
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/*/*",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-resource-creation-role"
            ]
          }
        }
      },
      {
        Sid       = "AllowAccessFromAccessPoint"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "s3:DataAccessPointArn" = aws_s3_access_point.sf_ap.arn
          }
        }
      },
      {
        Sid       = "DenyNonTLSRequests"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "EnforceModernTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
        Condition = {
          NumericLessThan = {
            "s3:TlsVersion" = "1.2"
          }
        }
      }
    ]
  })
}
