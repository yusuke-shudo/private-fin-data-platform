terraform {
  required_version = "~> 1.15.0"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.17.0"
    }
  }
}

provider "snowflake" {
  organization_name          = var.sf_organization_name
  account_name               = var.sf_account_name
  user                       = "cicd_infra_engineer_user"
  role                       = "cicd_infra_engineer_role"
  authenticator              = "WORKLOAD_IDENTITY"
  workload_identity_provider = "OIDC"
}
