-- schemachange migration: create initial raw tables for DATALAKE_DB
-- This file manages raw ingestion tables for SBI Securities and Monex Securities

CREATE TABLE IF NOT EXISTS datalake_db.sbi_securities.futures_options_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_futures_options_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE TABLE IF NOT EXISTS datalake_db.monex_securities.all_trade_and_cash_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_all_trade_and_cash_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
