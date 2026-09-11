CREATE STREAM IF NOT EXISTS datalake_db.paypay_bank.stream_on_stage_paypay_bank
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.paypay_bank.stage_paypay_bank_stream_triggered
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.paypay_bank.work_from_stream_paypay_bank (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE STREAM IF NOT EXISTS datalake_db.orico_credit.stream_on_stage_orico_credit
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.orico_credit.stage_orico_credit_stream_triggered
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.orico_credit.work_from_stream_orico_credit (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE STREAM IF NOT EXISTS datalake_db.sbi_securities.stream_on_stage_sbi_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.sbi_securities.stage_sbi_securities_stream_triggered
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.sbi_securities.work_from_stream_sbi_securities (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE STREAM IF NOT EXISTS datalake_db.monex_securities.stream_on_stage_monex_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.monex_securities.stage_monex_securities_stream_triggered
;

CREATE TRANSIENT TABLE IF NOT EXISTS datalake_db.monex_securities.work_from_stream_monex_securities (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
