-- dbt build tasks triggered by raw table updates
-- One task per raw data source to execute only relevant dbt models
-- Uses dbt Projects on Snowflake for native execution

CREATE TASK IF NOT EXISTS "DATAWAREHOUSE_DB"."COMMON"."task_dbt_build_on_paypay_home_loan_raw"
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK "DATAWAREHOUSE_DB"."COMMON"."task_dbt_build_on_paypay_home_loan_raw"
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  WHEN SYSTEM$STREAM_HAS_DATA('DATAWAREHOUSE_DB.COMMON.stream_for_dbt_build_paypay_home_loan')
AS
  EXECUTE DBT BUILD JOB ON DBT PROJECT 'private_fin_data_platform_dev'
  (
    COMMAND = 'dbt build --target cicd_dev -s +stg_paypay_bank__home_loan_schedule'
  )
;

CREATE TASK IF NOT EXISTS "DATAWAREHOUSE_DB"."COMMON"."task_dbt_build_on_orico_home_reform_raw"
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK "DATAWAREHOUSE_DB"."COMMON"."task_dbt_build_on_orico_home_reform_raw"
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  WHEN SYSTEM$STREAM_HAS_DATA('DATAWAREHOUSE_DB.COMMON.stream_for_dbt_build_orico_home_reform')
AS
  EXECUTE DBT BUILD JOB ON DBT PROJECT 'private_fin_data_platform_dev'
  (
    COMMAND = 'dbt build --target cicd_dev -s +stg_orico_credit__home_reform_loan_schedule'
  )
;
