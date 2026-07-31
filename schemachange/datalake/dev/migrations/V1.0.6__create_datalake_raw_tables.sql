-- schemachange migration: create initial raw tables for DATALAKE_DB
-- This file manages raw ingestion tables for SBI Securities

CREATE TABLE IF NOT EXISTS datalake_db.sbi_securities.domestic_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_domestic_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;

CREATE TABLE IF NOT EXISTS datalake_db.sbi_securities.foreign_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_foreign_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
