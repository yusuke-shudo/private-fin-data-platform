-- schemachange migration: create initial raw tables for DATALAKE_DB
-- This file manages raw ingestion tables for PayPay Bank and SBI Securities

CREATE TABLE IF NOT EXISTS DATALAKE_DB.PAYPAY_BANK.home_loan_schedule_raw (
  ingest_at    TIMESTAMP_NTZ  NOT NULL,
  file_path    STRING         NOT NULL,
  line_number  NUMBER         NOT NULL,
  raw_payload  VARIANT        NOT NULL,
  CONSTRAINT PK_home_loan_schedule_raw PRIMARY KEY (file_path) RELY
);

CREATE TABLE IF NOT EXISTS DATALAKE_DB.SBI_SECURITIES.sbi_tokutei_profit_loss_report_raw (
  ingest_at    TIMESTAMP_NTZ  NOT NULL,
  file_path    STRING         NOT NULL,
  line_number  NUMBER         NOT NULL,
  raw_payload  VARIANT        NOT NULL,
  CONSTRAINT PK_sbi_tokutei_profit_loss_report_raw PRIMARY KEY (file_path) RELY
);
