-- schemachange migration: create initial raw tables for DATALAKE_DB
-- This file manages raw ingestion tables for SBI Securities

-- ===== SBI Securities: sbi_tokutei_profit_loss_report_raw =====

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  DROP CONSTRAINT pk_sbi_tokutei_profit_loss_report_raw;

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  RENAME TO tokutei_profit_loss_report_raw;

ALTER TABLE datalake_db.sbi_securities.tokutei_profit_loss_report_raw
  ADD CONSTRAINT pk_tokutei_profit_loss_report_raw PRIMARY KEY (file_path, line_number);
