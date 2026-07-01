CREATE OR REPLACE PROCEDURE datalake_db.common.proc_load_raw_full_refresh(
	p_target_table_fqn  VARCHAR,
	p_stage_path        VARCHAR,
	p_file_format_fqn   VARCHAR
)
	RETURNS VARCHAR
	LANGUAGE SQL
	EXECUTE AS OWNER
AS
$$
DECLARE

  sql        VARCHAR;

BEGIN

  TRUNCATE TABLE IDENTIFIER(:p_target_table_fqn);

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || :p_target_table_fqn,
    'FROM (',
    '  SELECT',
    '    CONVERT_TIMEZONE(\'UTC\', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ingest_at_utc,',
    '    METADATA$FILENAME AS file_path,',
    '    METADATA$FILE_ROW_NUMBER AS line_number,',
    '    $1 AS raw_text',
    '  FROM',
    '    @' || :p_stage_path,
    '  )',
    'FILE_FORMAT = (',
    '  FORMAT_NAME = \'' || :p_file_format_fqn || '\'',
    ')',
    'ON_ERROR = ABORT_STATEMENT'
  );
  EXECUTE IMMEDIATE :sql;

  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_load_raw_full_refresh(VARCHAR, VARCHAR, VARCHAR)
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;

CREATE OR REPLACE PROCEDURE datalake_db.common.proc_load_raw_full_refresh_with_transaction(
	p_target_table_fqn  VARCHAR,
	p_stage_path        VARCHAR,
	p_file_format_fqn   VARCHAR
)
	RETURNS VARCHAR
	LANGUAGE SQL
	EXECUTE AS OWNER
AS
$$
DECLARE

  tmp_table  VARCHAR  DEFAULT :p_target_table_fqn || '_tmp';
  sql        VARCHAR;

BEGIN

  CREATE OR REPLACE TEMP TABLE
    IDENTIFIER(:tmp_table)
  LIKE
    IDENTIFIER(:p_target_table_fqn)
  ;

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || tmp_table,
    'FROM (',
    '  SELECT',
    '    CONVERT_TIMEZONE(\'UTC\', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ingest_at_utc,',
    '    METADATA$FILENAME AS file_path,',
    '    METADATA$FILE_ROW_NUMBER AS line_number,',
    '    $1 AS raw_text',
    '  FROM',
    '    @' || :p_stage_path,
    '  )',
    'FILE_FORMAT = (',
    '  FORMAT_NAME = \'' || :p_file_format_fqn || '\'',
    ')',
    'ON_ERROR = ABORT_STATEMENT'
  );
  EXECUTE IMMEDIATE :sql;


  BEGIN TRANSACTION;

  DELETE FROM
    IDENTIFIER(:p_target_table_fqn)
  ;
  INSERT INTO
    IDENTIFIER(:p_target_table_fqn)
  SELECT
    *
  FROM
      IDENTIFIER(:tmp_table)
  ;

  COMMIT;


  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_load_raw_full_refresh_with_transaction(VARCHAR, VARCHAR, VARCHAR)
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;

CREATE OR REPLACE PROCEDURE datalake_db.common.proc_load_csv_to_json_full_refresh(
	p_target_table_fqn  VARCHAR,
	p_stage_path        VARCHAR,
	p_file_format_fqn   VARCHAR,
	p_file_pattern      VARCHAR
)
	RETURNS VARCHAR
	LANGUAGE SQL
	EXECUTE AS OWNER
AS
$$
DECLARE

  tmp_table  VARCHAR  DEFAULT :p_target_table_fqn || '_tmp';
  sql        VARCHAR;

BEGIN

  sql := CONCAT_WS(
    '\n',
    'CREATE OR REPLACE TEMP TABLE',
    '  ' || :tmp_table,
    'USING TEMPLATE (',
    '  SELECT',
    '    ARRAY_AGG(OBJECT_CONSTRUCT(*))',
    '  FROM TABLE(INFER_SCHEMA(',
    '    LOCATION => \'@' || :p_stage_path || '\',',
    '    FILE_FORMAT => \'' || :p_file_format_fqn || '\'',
    '  ))',
    ')'
  );
  EXECUTE IMMEDIATE :sql;

  ALTER TABLE
    IDENTIFIER(:tmp_table)
  ADD COLUMN
    file_path    VARCHAR,
    line_number  NUMBER
  ;

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || tmp_table,
    'FROM',
    '  @' || :p_stage_path,
    'FILE_FORMAT = (',
    '  FORMAT_NAME = \'' || :p_file_format_fqn || '\',',
    '  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE',
    ')',
    'PATTERN = \'' || :p_file_pattern || '\'',
    'MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE',
    'INCLUDE_METADATA = (file_path = METADATA$FILENAME, line_number = METADATA$FILE_ROW_NUMBER)',
    'ON_ERROR = ABORT_STATEMENT'
  );
  EXECUTE IMMEDIATE :sql;

  TRUNCATE TABLE IDENTIFIER(:p_target_table_fqn);

  INSERT INTO
    IDENTIFIER(:p_target_table_fqn)
  SELECT
    CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ingest_at_utc,
    file_path,
    line_number,
    OBJECT_DELETE(
      OBJECT_CONSTRUCT(*),
      'FILE_PATH', 'LINE_NUMBER'
    ) AS data_json
  FROM
    IDENTIFIER(:tmp_table)
  ;

  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_load_csv_to_json_full_refresh(VARCHAR, VARCHAR, VARCHAR, VARCHAR)
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;

CREATE OR REPLACE PROCEDURE datalake_db.common.proc_task_load_raw_0300()
	RETURNS VARCHAR
	LANGUAGE SQL
	EXECUTE AS OWNER
AS
$$
DECLARE

  result  VARCHAR;

BEGIN

  BEGIN
    CALL datalake_db.common.proc_load_raw_full_refresh(
      'datalake_db.paypay_bank.home_loan_schedule_raw',
      'datalake_db.paypay_bank.stage_paypay_bank/home_loan_schedule/',
      'datalake_db.common.ff_nodelimiter_sjis'
    );
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error loading PayPay home loan schedule: %', :SQLERRM;
  END;

  BEGIN
    CALL datalake_db.common.proc_load_raw_full_refresh(
      'datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw',
      'datalake_db.sbi_securities.stage_sbi_securities/profit_loss_report/',
      'datalake_db.common.ff_nodelimiter_sjis'
    );
  EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Error loading SBI tokutei profit/loss report: %', :SQLERRM;
  END;

  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_task_load_raw_0300()
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;
