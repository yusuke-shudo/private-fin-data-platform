-- schemachange migration: rename ingest_at_utc to ingested_at_utc and fix primary key
-- Context: Column naming should follow standard convention (ingested_at_utc instead of ingest_at_utc)
--          Primary key was incorrectly defined as (file_path) only, should be (file_path, line_number)

-- ===== PayPay Bank: home_loan_schedule_raw =====

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_raw
  DROP CONSTRAINT pk_home_loan_schedule_raw;

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_raw
  RENAME COLUMN ingest_at_utc TO ingested_at_utc;

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_raw
  ADD CONSTRAINT pk_home_loan_schedule_raw PRIMARY KEY (file_path, line_number);

-- ===== PayPay Bank: home_loan_schedule_json =====

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_json
  DROP CONSTRAINT pk_home_loan_schedule_json;

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_json
  RENAME COLUMN ingest_at_utc TO ingested_at_utc;

ALTER TABLE datalake_db.paypay_bank.home_loan_schedule_json
  ADD CONSTRAINT pk_home_loan_schedule_json PRIMARY KEY (file_path, line_number);

-- ===== SBI Securities: sbi_tokutei_profit_loss_report_raw =====

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  DROP CONSTRAINT pk_sbi_tokutei_profit_loss_report_raw;

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  RENAME COLUMN ingest_at_utc TO ingested_at_utc;

ALTER TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  ADD CONSTRAINT pk_sbi_tokutei_profit_loss_report_raw PRIMARY KEY (file_path, line_number);
