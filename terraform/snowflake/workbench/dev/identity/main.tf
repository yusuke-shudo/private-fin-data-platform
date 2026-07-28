locals {
  workbench_owner_slug    = upper(replace(var.owner, "-", "_"))
  workbench_identity_name = "WORKBENCH_${local.workbench_owner_slug}"
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
  name                = "${local.workbench_identity_name}_WH"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  initially_suspended = true
  comment             = "Developer workbench warehouse for ${var.owner} | ${local.managed_comment}"
}

resource "snowflake_account_role" "workbench" {
  name    = "${local.workbench_identity_name}_ROLE"
  comment = "Developer workbench role for ${var.owner} (dbt execution) | ${local.managed_comment}"
}

resource "snowflake_service_user" "workbench" {
  name              = "${local.workbench_identity_name}_USER"
  default_role      = snowflake_account_role.workbench.name
  default_warehouse = snowflake_warehouse.workbench.name
  default_workload_identity {
    aws {
      arn = var.aws_iam_role_arn
    }
  }
  abort_detached_query         = true
  lock_timeout                 = 10
  statement_timeout_in_seconds = 1800
  comment                      = "Service user for developer workbench (${var.owner}) via AWS IAM Workload Identity | ${local.managed_comment}"
}

resource "snowflake_grant_privileges_to_account_role" "workbench_warehouse_usage" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.workbench.name
  }
}

# ==========================================
# DATALAKE_DB 関連の権限設定
# ==========================================

resource "snowflake_grant_privileges_to_account_role" "workbench_datalake_read" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = "DATALAKE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datalake_schemas_usage" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_schema {
    all_schemas_in_database = "DATALAKE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datalake_future_schemas_usage" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_schema {
    future_schemas_in_database = "DATALAKE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datalake_tables_read" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = "DATALAKE_DB"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datalake_future_tables_read" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = "DATALAKE_DB"
    }
  }
}

# ==========================================
# DATAWAREHOUSE_DB 関連の権限設定
# ==========================================

resource "snowflake_grant_privileges_to_account_role" "workbench_datawarehouse_read_and_write" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE", "CREATE SCHEMA"]
  on_account_object {
    object_type = "DATABASE"
    object_name = "DATAWAREHOUSE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datawarehouse_schemas_usage" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_schema {
    all_schemas_in_database = "DATAWAREHOUSE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datawarehouse_future_schemas_usage" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["USAGE"]
  on_schema {
    future_schemas_in_database = "DATAWAREHOUSE_DB"
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datawarehouse_tables_read" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = "DATAWAREHOUSE_DB"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "workbench_datawarehouse_future_tables_read" {
  account_role_name = snowflake_account_role.workbench.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = "DATAWAREHOUSE_DB"
    }
  }
}

# ==========================================
# ロール付与
# ==========================================

resource "snowflake_grant_account_role" "workbench_user_role" {
  role_name = snowflake_account_role.workbench.name
  user_name = snowflake_service_user.workbench.name
}

resource "snowflake_grant_account_role_to_account_role" "workbench_to_sysadmin" {
  parent_role_name = "SYSADMIN"
  grant_role_name  = snowflake_account_role.workbench.name
}
