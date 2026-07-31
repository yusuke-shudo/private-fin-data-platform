locals {
  workbench_identity_name = "platform-workbench-${var.owner}"

  workbench_common_tags = {
    Project     = "private-fin-data-platform"
    ManagedBy   = "Terraform"
    Environment = var.env
    Scope       = "workbench"
    Owner       = var.owner
  }
}

data "aws_iam_policy_document" "workbench_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workbench_instance_role" {
  provider           = aws.resource_creation
  name               = local.workbench_identity_name
  assume_role_policy = data.aws_iam_policy_document.workbench_assume_role.json

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_identity_name
    Role = "workbench-identity"
  })
}

resource "aws_iam_role_policy_attachment" "workbench_ssm_core" {
  provider   = aws.resource_creation
  role       = aws_iam_role.workbench_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "workbench_instance_profile" {
  provider = aws.resource_creation
  name     = local.workbench_identity_name
  role     = aws_iam_role.workbench_instance_role.name

  tags = merge(local.workbench_common_tags, {
    Name = local.workbench_identity_name
    Role = "workbench-identity"
  })
}

# ==========================================
# Amazon Bedrock 接続用の最小権限設定（追加部分）
# ==========================================

# 1. モデルの呼び出しとストリーミング出力のみを許可するポリシー文書の定義
data "aws_iam_policy_document" "workbench_bedrock_invoke" {
  statement {
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["*"]
  }
}

# 2. 上記のポリシーをインラインポリシーとしてEC2のロールにアタッチ
resource "aws_iam_role_policy" "workbench_bedrock_minimal" {
  provider = aws.resource_creation
  name     = "bedrock-minimal-invoke-policy"
  role     = aws_iam_role.workbench_instance_role.id
  policy   = data.aws_iam_policy_document.workbench_bedrock_invoke.json
}
