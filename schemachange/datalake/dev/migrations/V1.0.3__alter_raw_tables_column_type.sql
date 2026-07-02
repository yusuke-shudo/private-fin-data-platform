-- schemachange migration: alter raw table column types from VARIANT to VARCHAR
-- Context: Raw files are ingested as plain text (CSV). VARIANT type caused parsing issues.
--          Renaming raw_payload to raw_text for semantic clarity.
-- Method: Table rebuild with SWAP for zero-downtime migration (atomic operation)
-- Changes:
--   - Rename raw_payload → raw_text (both tables)
--   - Modify column type VARIANT → VARCHAR (both tables)

-- ===== PayPay Bank: home_loan_schedule_raw =====

CREATE TABLE datalake_db.paypay_bank.home_loan_schedule_raw_new (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  raw_text       VARCHAR        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_raw PRIMARY KEY (file_path) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

INSERT INTO datalake_db.paypay_bank.home_loan_schedule_raw_new
  SELECT ingest_at_utc, file_path, line_number, TO_JSON(raw_payload)
  FROM datalake_db.paypay_bank.home_loan_schedule_raw
;

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_raw
  SWAP WITH datalake_db.paypay_bank.home_loan_schedule_raw_new
;

DROP TABLE datalake_db.paypay_bank.home_loan_schedule_raw_new;

-- ===== SBI Securities: sbi_tokutei_profit_loss_report_raw =====

CREATE TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw_new (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  raw_text       VARCHAR        NOT NULL,
  CONSTRAINT pk_sbi_tokutei_profit_loss_report_raw PRIMARY KEY (file_path) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

INSERT INTO datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw_new
  SELECT ingest_at_utc, file_path, line_number, TO_JSON(raw_payload)
  FROM datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
;

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  SWAP WITH datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw_new
;

DROP TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw_new;
