-- schemachange migration: create daily full-refresh task for PayPay Bank home loan schedule raw table
-- Requirement: run once a day, read from S3 paypay_bank/home_loan_schedule/, and fully replace target rows

CREATE SCHEMA IF NOT EXISTS DATALAKE_DB.COMMON;

CREATE OR REPLACE FILE FORMAT DATALAKE_DB.COMMON.FF_NODELIMITER
  TYPE = 'CSV'
  FIELD_DELIMITER = NONE
  SKIP_HEADER = 0
  ENCODING = 'UTF8';

CREATE OR REPLACE PROCEDURE DATALAKE_DB.COMMON.SP_LOAD_RAW_FULL_REFRESH(
  P_TARGET_TABLE_FQN  STRING,
  P_STAGE_PATH        STRING,
  P_FILE_FORMAT_FQN   STRING,
  P_FILE_PATTERN      STRING
)
  RETURNS STRING
  LANGUAGE SQL
  EXECUTE AS OWNER
AS
$$
BEGIN
  TRUNCATE TABLE IDENTIFIER(:P_TARGET_TABLE_FQN);

  COPY INTO IDENTIFIER(:P_TARGET_TABLE_FQN)
    (ingest_at, file_path, line_number, raw_payload)
  FROM (
    SELECT
      CURRENT_TIMESTAMP()                                       AS ingest_at,
      METADATA$FILENAME                                         AS file_path,
      METADATA$FILE_ROW_NUMBER                                  AS line_number,
      TO_VARIANT($1)                                            AS raw_payload
    FROM @IDENTIFIER(:P_STAGE_PATH)
  )
  FILE_FORMAT = (FORMAT_NAME = 'DATALAKE_DB.COMMON.FF_NODELIMITER')
  PATTERN = :P_FILE_PATTERN
  FORCE = TRUE
  ON_ERROR = 'ABORT_STATEMENT';

  RETURN 'SUCCESS';
END;
$$
;
