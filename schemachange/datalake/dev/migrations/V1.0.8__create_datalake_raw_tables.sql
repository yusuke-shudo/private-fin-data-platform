-- schemachange migration: create raw table for Orico Credit

CREATE TABLE IF NOT EXISTS datalake_db.orico_credit.home_reform_loan_schedule_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_home_reform_loan_schedule_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
