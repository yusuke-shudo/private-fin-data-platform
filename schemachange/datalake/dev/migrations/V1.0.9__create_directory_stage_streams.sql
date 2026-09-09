CREATE STREAM IF NOT EXISTS datalake_db.paypay_bank.stream_paypay_bank_masters_direct_dir
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.paypay_bank.stage_paypay_bank_masters_direct_dir
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.paypay_bank.work_stream_paypay_bank_masters_direct_dir (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE STREAM IF NOT EXISTS datalake_db.orico_credit.stream_orico_credit_masters_direct_dir
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.orico_credit.stage_orico_credit_masters_direct_dir
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.orico_credit.work_stream_orico_credit_masters_direct_dir (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
