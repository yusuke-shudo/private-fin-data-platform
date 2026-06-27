-- schemachange migration: create daily full-refresh task for PayPay Bank home loan schedule raw table
-- Requirement: run once a day, read from S3 paypay_bank/home_loan_schedule/, and fully replace target rows

CREATE SCHEMA IF NOT EXISTS DATALAKE_DB.COMMON;

CREATE OR REPLACE FILE FORMAT DATALAKE_DB.COMMON.FF_NODELIMITER
  TYPE = 'CSV'
  FIELD_DELIMITER = NONE
  SKIP_HEADER = 0
  ENCODING = 'UTF8';

CREATE OR REPLACE PROCEDURE DATALAKE_DB.COMMON.SP_LOAD_RAW_FULL_REFRESH(
  p_target_table_fqn  STRING,
  p_stage_path        STRING,
  p_file_format_fqn   STRING,
  p_file_pattern      STRING
)
  RETURNS STRING
  LANGUAGE SQL
  EXECUTE AS OWNER
AS
$$
BEGIN
  TRUNCATE TABLE IDENTIFIER(:p_target_table_fqn);

  COPY INTO
    IDENTIFIER(:p_target_table_fqn)
  FROM (
    SELECT
      CURRENT_TIMESTAMP() AS ingest_at,
      METADATA$FILENAME AS file_path,
      METADATA$FILE_ROW_NUMBER AS line_number,
      TO_VARIANT($1) AS raw_payload
    FROM
      @IDENTIFIER(:p_stage_path)
  )
  FILE_FORMAT = (FORMAT_NAME = :p_file_format_fqn)
  PATTERN = :p_file_pattern
  FORCE = TRUE
  ON_ERROR = 'ABORT_STATEMENT'
  ;

  RETURN 'SUCCESS';
END;
$$
;
