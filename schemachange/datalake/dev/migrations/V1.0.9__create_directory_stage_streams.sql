-- Create one directory-table stream per source master area.
-- Streams are versioned objects because their offsets are stateful.

CREATE STREAM IF NOT EXISTS datalake_db.paypay_bank.stream_paypay_bank_masters_direct_dir
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.paypay_bank.stage_paypay_bank_masters_direct_dir
;

CREATE STREAM IF NOT EXISTS datalake_db.orico_credit.stream_orico_credit_masters_direct_dir
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.orico_credit.stage_orico_credit_masters_direct_dir
;
