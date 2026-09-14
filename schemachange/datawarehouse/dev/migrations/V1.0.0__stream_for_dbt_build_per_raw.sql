-- Stream for dbt build automation (raw table updates)
-- One stream per raw data source to trigger corresponding dbt build tasks
-- Placed in DATAWAREHOUSE_DB.COMMON for centralized task orchestration

CREATE STREAM IF NOT EXISTS "DATAWAREHOUSE_DB"."COMMON"."stream_for_dbt_build_paypay_home_loan"
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON TABLE datalake_db.paypay_bank.home_loan_schedule_raw
;

CREATE STREAM IF NOT EXISTS "DATAWAREHOUSE_DB"."COMMON"."stream_for_dbt_build_orico_home_reform"
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON TABLE datalake_db.orico_credit.home_reform_loan_schedule_raw
;
