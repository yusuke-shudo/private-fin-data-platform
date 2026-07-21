locals {
  workbench_identity_name = "workbench_${var.owner}"
  
  workbench_common_tags = {
    Project     = "private-fin-data-platform"
    ManagedBy   = "Terraform"
    Environment = var.env
    Scope       = "workbench"
    Owner       = var.owner
  }
  
  managed_comment = "Managed by Terraform (repo: private-fin-data-platform)"
}

resource "snowflake_warehouse" "workbench" {
  name              = "${local.workbench_identity_name}_wh"
  warehouse_size    = "XSMALL"
  auto_suspend      = 60
  initially_suspended = true
  comment           = "Developer workbench warehouse for ${var.owner} | ${local.managed_comment}"
}

resource "snowflake_account_role" "workbench" {
  name    = "${local.workbench_identity_name}_role"
  comment = "Developer workbench role for ${var.owner} (dbt execution) | ${local.managed_comment}"
}

resource "snowflake_service_user" "workbench" {
  name         = "${local.workbench_identity_name}_user"
  default_role = snowflake_account_role.workbench.name
  default_warehouse = snowflake_warehouse.workbench.name
  default_workload_identity_federation {
    identity_type = "AWS_IAM"
    arn           = var.aws_iam_role_arn
  }
  abort_detached_query        = true
  lock_timeout                = 10
  statement_timeout_in_seconds = 1800
  comment                     = "Service user for developer workbench (${var.owner}) via AWS IAM Workload Identity | ${local.managed_comment}"
}

resource "snowflake_grant_privileges_to_account_role" "workbench_warehouse_usage" {
  role_name = snowflake_account_role.workbench.name

  privileges = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.workbench.name
  }
}

resource "snowflake_grant_account_role" "workbench_user_role" {
  role_name = snowflake_account_role.workbench.name
  user_name = snowflake_service_user.workbench.name
}
