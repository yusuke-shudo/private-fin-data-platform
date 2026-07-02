-- schemachange migration: add sample JSON table

-- Create sample table for JSON-based raw data ingestion
CREATE TABLE IF NOT EXISTS datalake_db.paypay_bank.home_loan_schedule_json (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  data_json      VARIANT        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_json PRIMARY KEY (file_path) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
