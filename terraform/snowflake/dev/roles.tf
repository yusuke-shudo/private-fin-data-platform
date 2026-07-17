# ==============================================================================
# 1. 閲覧専用ロール
# ==============================================================================
resource "snowflake_account_role" "read_only" {
  name = "app_read_only_role"
}

# ==============================================================================
# 2. Datalake更新・開発用ロール
# ==============================================================================
resource "snowflake_account_role" "datalake_write" {
  name = "app_datalake_write_role"
}

resource "snowflake_grant_account_role" "datalake_write_inherits_read_only" {
  role_name        = snowflake_account_role.read_only.name
  parent_role_name = snowflake_account_role.datalake_write.name
}
