# =========================================================================
# データレイク用 S3バケット一式
#
# 命名規則
#   バケット               : <project_prefix>-<env>-<用途>   例: yskshd-fin-data-dev-datalake
#   Snowflake連携IAMロール : <バケット名>-sf-role
#   Snowflake連携アクセスポイント : <バケット名>-sf-ap
# 用途は datalake / iceberg のように増える想定。用途ごとに .tf ファイルを分ける。
# =========================================================================
locals {
  aws_region = "ap-northeast-1"
  account_id = data.aws_caller_identity.current.account_id

  datalake_bucket_name  = "${var.project_prefix}-${var.env}-datalake"
  datalake_sf_role_name = "${local.datalake_bucket_name}-sf-role"
  datalake_sf_ap_name   = "${local.datalake_bucket_name}-sf-ap"
  datalake_sf_ap_arn    = "arn:aws:s3:${local.aws_region}:${local.account_id}:accesspoint/${local.datalake_sf_ap_name}"
}

# =========================================================================
# バケット本体と基本設定
# =========================================================================
resource "aws_s3_bucket" "datalake" {
  provider      = aws.resource_creation
  bucket        = local.datalake_bucket_name
  force_destroy = false
  tags = {
    Name        = local.datalake_bucket_name
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "datalake" {
  provider                = aws.resource_creation
  bucket                  = aws_s3_bucket.datalake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datalake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.datalake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "datalake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.datalake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# =========================================================================
# Snowflake連携用 IAMロール
# =========================================================================
resource "aws_iam_role" "datalake_sf" {
  provider = aws.resource_creation
  name     = local.datalake_sf_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      merge(
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            AWS = var.sf_user_arn != "" ? var.sf_user_arn : "arn:aws:iam::${local.account_id}:root"
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
    Name        = local.datalake_sf_role_name
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

# アクセスポイントポリシーがロールARNを解決できるようIAMの伝播を待つ
resource "time_sleep" "datalake_sf_role_propagation" {
  depends_on      = [aws_iam_role.datalake_sf]
  create_duration = "30s"
}

# =========================================================================
# 外部システム（Snowflake）専用のアクセスポイント
# =========================================================================
resource "aws_s3_access_point" "datalake_sf" {
  provider   = aws.resource_creation
  bucket     = aws_s3_bucket.datalake.id
  name       = local.datalake_sf_ap_name
  depends_on = [time_sleep.datalake_sf_role_propagation]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSnowflakeAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.datalake_sf.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          local.datalake_sf_ap_arn,
          "${local.datalake_sf_ap_arn}/object/*"
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
        Resource = "${local.datalake_sf_ap_arn}/object/*"
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = [
              aws_iam_role.datalake_sf.arn
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
resource "aws_s3_bucket_policy" "datalake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.datalake.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyDirectAccessExceptAccessPointAndBootstrap"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "s3:DataAccessPointArn" = aws_s3_access_point.datalake_sf.arn
          }
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::${local.account_id}:root",
              "arn:aws:iam::${local.account_id}:role/aws-reserved/sso.amazonaws.com/*/*",
              "arn:aws:iam::${local.account_id}:role/github-actions-resource-creation-role"
            ]
          }
        }
      },
      {
        Sid       = "AllowAccessFromAccessPoint"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "s3:DataAccessPointArn" = aws_s3_access_point.datalake_sf.arn
          }
        }
      },
      {
        Sid       = "DenyNonTLSRequests"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
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
        Resource = [
          aws_s3_bucket.datalake.arn,
          "${aws_s3_bucket.datalake.arn}/*"
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

# =========================================================================
# S3 イベント通知（Snowpipe auto-ingest 用）
#
# Snowflakeは「1 AWSリージョンにつきSQSキューは1つ」を使い回す仕様のため
# (https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3)、
# snowpipe_queue_arn は特定のpipe専用ではなく、このSnowflakeアカウント・
# このリージョン向けの共有キューARN。新しいpipeを追加する際も変数は増やさず、
# 下の queue ブロックを一つ足すだけでよい。
#
# 前提: Snowpipe対象のS3バケットは全て同一リージョン(ap-northeast-1)。
# 別リージョンにバケットを追加する場合はキューARNが変わるため、
# snowpipe_queue_arn をリージョンキーの map(string) 化する等の見直しが必要。
#
# 通知設定は bucket ごとに1つの aws_s3_bucket_notification に集約する必要がある
# (S3 APIの notification configuration は部分更新ではなく丸ごと置換のため)。
#
# デプロイ順序: Snowflake側で最初のpipeを作成し、出力される notification_channel
# (SQSキューARN)を GitHub変数 AWS_S3_SNOWPIPE_QUEUE_ARN に設定してから、
# このリソースを apply する。未設定(空文字)の間は queue ブロックが生成されず、
# 通知は無効のまま。
# =========================================================================
resource "aws_s3_bucket_notification" "datalake" {
  provider = aws.resource_creation
  bucket   = aws_s3_bucket.datalake.id

  dynamic "queue" {
    for_each = var.snowpipe_queue_arn != "" ? [var.snowpipe_queue_arn] : []
    content {
      queue_arn     = queue.value
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "monex_securities/all_trade_and_cash_history/"
    }
  }
}
