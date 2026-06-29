-- schemachange migration: create daily full-refresh task for PayPay Bank home loan schedule raw table
-- Requirement: run once a day, read from S3 paypay_bank/home_loan_schedule/, and fully replace target rows

CREATE SCHEMA IF NOT EXISTS datalake_db.common;

CREATE OR REPLACE FILE FORMAT datalake_db.common.ff_nodelimiter
  TYPE = 'CSV'
  FIELD_DELIMITER = NONE
  SKIP_HEADER = 0
  ENCODING = 'UTF8'
;

CREATE OR REPLACE FILE FORMAT datalake_db.common.ff_csv_skipheader1
  TYPE = 'CSV'
  SKIP_HEADER = 1
  ENCODING = 'UTF8'
;

CREATE OR REPLACE PROCEDURE datalake_db.common.sp_load_raw_full_refresh(
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
DECLARE
  sql STRING;
BEGIN
  TRUNCATE TABLE IDENTIFIER(:p_target_table_fqn);

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || :p_target_table_fqn,
    'FROM(',
    '  SELECT',
    '    CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ingest_at_utc,',
    '    METADATA$FILENAME AS file_path,',
    '    METADATA$FILE_ROW_NUMBER AS line_number,',
    '    ARRAY_CONSTRUCT(*) AS raw_payload,',
    '  FROM',
    '    @' || :p_stage_path,
    ')',
    'FILE_FORMAT = (FORMAT_NAME = \'' || :p_file_format_fqn || '\')',
    'PATTERN = \'' || :p_file_pattern || '\'',
    'FORCE = TRUE',
    'ON_ERROR = ABORT_STATEMENT'
  );
  EXECUTE IMMEDIATE :sql;

  RETURN 'SUCCESS';
END;
$$
;

CREATE OR REPLACE TASK datalake_db.common.task_load_raw_0300
  SCHEDULE = 'USING CRON 0 3 * * * Asia/Tokyo'
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
AS
CALL datalake_db.common.sp_load_raw_full_refresh(
  'datalake_db.paypay_bank.home_loan_schedule_raw',
  'datalake_db.paypay_bank.paypay_bank_stage/home_loan_schedule/',
  'datalake_db.common.ff_nodelimiter',
  '.*\\.csv'
)
;

ALTER TASK datalake_db.common.task_load_raw_0300 RESUME;
