terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50.0"
    }
  }
}

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

data "aws_region" "current" {
  provider = aws.resource_creation
}

