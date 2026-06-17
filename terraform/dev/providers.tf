terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50.0"
    }
    snowflake = {
      source = "snowflakedb/snowflake"
      version = "~> 2.17.0"
    }
  }
}

# =========================================================================
# 1. AWS Provider 設定
# =========================================================================

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  alias  = "resource_creation"
  region = "ap-northeast-1"

  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-resource-creation-role"
    session_name = "TerraformDeployment"
  }
}

# =========================================================================
# 2. Snowflake Provider 設定
# =========================================================================
provider "snowflake" {
  organization_name          = var.sf_organization_name
  account_name               = var.sf_account_name
  user                       = "cicd_infra_engineer_user"
  role                       = "cicd_infra_engineer_role"
  authenticator              = "WORKLOAD_IDENTITY"
  workload_identity_provider = "OIDC"
}
