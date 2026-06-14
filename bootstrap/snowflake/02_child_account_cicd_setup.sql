-- ==============================================================================
-- 2. 子アカウントでの手作業（実行先: DEVアカウント / PRDアカウント それぞれ）
-- 
-- ※注意: 実行前に、下部にある OIDC の SUBJECT 内の <ENVIRONMENT_NAME> 部分を
--       DEVアカウントなら「dev」、PRDアカウントなら「prd」に書き換えてください。
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- ウェアハウスの作成と所有権の設定（実行ロール: SYSADMIN）
-- ------------------------------------------------------------------------------
USE ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE cicd_infra_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Dedicated warehouse for CI/CD infrastructure and schema deployment'
;

CREATE OR REPLACE WAREHOUSE cicd_data_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Dedicated warehouse for CI/CD dbt data transformations'
;

-- ------------------------------------------------------------------------------
-- ロールの作成と権限の紐付け（実行ロール: SECURITYADMIN）
-- ------------------------------------------------------------------------------
USE ROLE SECURITYADMIN;

CREATE OR REPLACE ROLE cicd_infra_engineer_role;
GRANT ROLE cicd_infra_engineer_role TO ROLE SYSADMIN;

CREATE OR REPLACE ROLE cicd_data_engineer_role;
GRANT ROLE cicd_data_engineer_role TO ROLE SYSADMIN;

GRANT USAGE ON WAREHOUSE cicd_infra_wh TO ROLE cicd_infra_engineer_role;
GRANT USAGE ON WAREHOUSE cicd_data_wh TO ROLE cicd_data_engineer_role;

-- ------------------------------------------------------------------------------
-- ユーザーの作成とロールの割り当て（実行ロール: USERADMIN）
-- ------------------------------------------------------------------------------
USE ROLE USERADMIN;

CREATE OR REPLACE USER cicd_infra_engineer_user
  TYPE = SERVICE
  DEFAULT_ROLE = cicd_infra_engineer_role
  DEFAULT_WAREHOUSE = cicd_infra_wh
  WORKLOAD_IDENTITY = (
    TYPE   = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:yusuke-shudo/private-fin-data-platform:environment:<ENVIRONMENT_NAME>-infra' -- ★devまたはprdに書き換え
  )
  ABORT_DETACHED_QUERY = TRUE
  LOCK_TIMEOUT = 0
  STATEMENT_TIMEOUT_IN_SECONDS = 300
  COMMENT = 'Service user for infrastructure deployment via GitHub Actions (repo: private-fin-data-platform)'
;
GRANT ROLE cicd_infra_engineer_role TO USER cicd_infra_engineer_user;

CREATE OR REPLACE USER cicd_data_engineer_user
  TYPE = SERVICE
  DEFAULT_ROLE = cicd_data_engineer_role
  DEFAULT_WAREHOUSE = cicd_data_wh
  WORKLOAD_IDENTITY = (
    TYPE   = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:yusuke-shudo/private-fin-data-platform:environment:<ENVIRONMENT_NAME>-data' -- ★devまたはprdに書き換え
  )
  ABORT_DETACHED_QUERY = TRUE
  LOCK_TIMEOUT = 10
  STATEMENT_TIMEOUT_IN_SECONDS = 1800
  COMMENT = 'Service user for dbt data transformations via GitHub Actions (repo: private-fin-data-platform)'
;
GRANT ROLE cicd_data_engineer_role TO USER cicd_data_engineer_user;
