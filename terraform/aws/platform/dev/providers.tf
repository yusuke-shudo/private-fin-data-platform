terraform {
  required_version = "~> 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"
    }
  }
}

provider "aws" {
  alias  = "token_fetcher"
  region = var.aws_region
}

data "aws_caller_identity" "current" {
  provider = aws.token_fetcher
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-resource-creation-role"
    session_name = "TerraformDeployment"
  }
}
