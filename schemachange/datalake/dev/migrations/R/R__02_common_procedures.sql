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

  sql  VARCHAR;

BEGIN

  TRUNCATE TABLE IDENTIFIER(:p_target_table_fqn);

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || :p_target_table_fqn,
    'FROM (',
    '  SELECT',
    '    CONVERT_TIMEZONE(\'UTC\', METADATA$START_SCAN_TIME)::TIMESTAMP_NTZ AS ingested_at_utc,',
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
    '    CONVERT_TIMEZONE(\'UTC\', METADATA$START_SCAN_TIME)::TIMESTAMP_NTZ AS ingested_at_utc,',
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

CREATE OR REPLACE PROCEDURE datalake_db.common.proc_load_raw_master_full_refresh_with_transaction(
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

  snapshot_table_fqn  VARCHAR  DEFAULT :p_target_table_fqn || '_snapshot';
  sql                 VARCHAR;

BEGIN
  -- Temporary delay for validating events arriving during task execution.
  CALL SYSTEM$WAIT(10, 'SECONDS');

  CREATE OR REPLACE TEMP TABLE
    IDENTIFIER(:snapshot_table_fqn)
  LIKE
    IDENTIFIER(:p_target_table_fqn)
  ;

  sql := CONCAT_WS(
    '\n',
    'COPY INTO',
    '  ' || snapshot_table_fqn,
    'FROM (',
    '  SELECT',
    '    CONVERT_TIMEZONE(\'UTC\', METADATA$START_SCAN_TIME)::TIMESTAMP_NTZ AS ingested_at_utc,',
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
    IDENTIFIER(:snapshot_table_fqn)
  ;

  COMMIT;


  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_load_raw_master_full_refresh_with_transaction(VARCHAR, VARCHAR, VARCHAR)
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
    CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS ingested_at_utc,
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

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.paypay_bank.home_loan_schedule_raw',
    'datalake_db.paypay_bank.stage_paypay_bank/masters/home_loan_schedule/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.orico_credit.home_reform_loan_schedule_raw',
    'datalake_db.orico_credit.stage_orico_credit/masters/home_reform_loan_schedule/',
    'datalake_db.common.ff_nodelimiter'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.sbi_securities.domestic_trade_history_raw',
    'datalake_db.sbi_securities.stage_sbi_securities/batch/domestic_trade_history/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.sbi_securities.foreign_trade_history_raw',
    'datalake_db.sbi_securities.stage_sbi_securities/batch/foreign_trade_history/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.sbi_securities.futures_options_trade_history_raw',
    'datalake_db.sbi_securities.stage_sbi_securities/batch/futures_options_trade_history/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.sbi_securities.tokutei_profit_loss_report_raw',
    'datalake_db.sbi_securities.stage_sbi_securities/batch/tokutei_profit_loss_report/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  CALL datalake_db.common.proc_load_raw_full_refresh(
    'datalake_db.monex_securities.all_trade_and_cash_history_raw',
    'datalake_db.monex_securities.stage_monex_securities/history/all_trade_and_cash_history/',
    'datalake_db.common.ff_nodelimiter_sjis'
  );

  RETURN 'SUCCESS';

END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_task_load_raw_0300()
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;

CREATE OR REPLACE PROCEDURE datalake_db.common.proc_load_raw_masters_from_stream(
  p_stream_fqn      VARCHAR,
  p_stage_fqn       VARCHAR,
  p_dataset_config  VARIANT
)
  RETURNS VARCHAR
  LANGUAGE SQL
  EXECUTE AS OWNER
AS
$$
DECLARE

  work_table_fqn        VARCHAR;
  dataname              VARCHAR;
  dataset_config_item   VARIANT;
  file_format_fqn       VARCHAR;
  target_table_fqn      VARCHAR;
  v_relative_path       VARCHAR;
  v_last_modified       TIMESTAMP_TZ;
  processed_count       NUMBER  DEFAULT 0;
  failed_count          NUMBER  DEFAULT 0;

BEGIN

  -- Determine work table FQN from stream FQN
  -- Example: datalake_db.paypay_bank.stream_paypay_bank_masters_direct_dir
  --       -> datalake_db.paypay_bank.work_stream_paypay_bank_masters_direct_dir
  work_table_fqn := REPLACE(
    :p_stream_fqn,
    'stream_',
    'work_stream_'
  );

  -- Insert all stream events into work table
  INSERT INTO IDENTIFIER(:work_table_fqn) (relative_path, last_modified)
  SELECT
    relative_path,
    last_modified
  FROM
    IDENTIFIER(:p_stream_fqn)
  ;

  -- Process work table records (only INSERT actions, and latest per relative_path)
  FOR v_relative_path, v_last_modified IN (
    SELECT
      relative_path,
      last_modified
    FROM
      IDENTIFIER(:work_table_fqn)
    WHERE
      metadata$action = 'INSERT'
    QUALIFY
      ROW_NUMBER() OVER (PARTITION BY relative_path ORDER BY last_modified DESC) = 1
    ORDER BY
      last_modified ASC
  ) DO

    BEGIN

      -- Extract data name from relative_path (first directory level)
      -- Example: home_loan_schedule/home_loan_schedule_raw.csv -> home_loan_schedule
      dataname := SPLIT_PART(:v_relative_path, '/', 1);
      dataset_config_item := :p_dataset_config[:dataname];

      -- If config exists for this data name, process it
      IF (dataset_config_item IS NOT NULL) THEN
        target_table_fqn := dataset_config_item:target_table::VARCHAR;
        file_format_fqn := dataset_config_item:file_format::VARCHAR;

        CALL datalake_db.common.proc_load_raw_master_full_refresh_with_transaction(
          :target_table_fqn,
          :p_stage_fqn || '/' || :v_relative_path,
          :file_format_fqn
        );
        processed_count := processed_count + 1;
      END IF;

      -- Delete all records (both INSERT and DELETE) with the same relative_path
      -- This happens regardless of whether the file was processed or matched
      DELETE FROM
        IDENTIFIER(:work_table_fqn)
      WHERE
        relative_path = :v_relative_path
      ;

    EXCEPTION
      WHEN OTHER THEN
        -- Log error but continue processing other records
        failed_count := failed_count + 1;
        CONTINUE;

    END;

  END FOR;

  RETURN 'PROCESSED:' || processed_count || ', FAILED:' || failed_count;

EXCEPTION
  WHEN OTHER THEN
    RAISE;
END;
$$
;

ALTER PROCEDURE datalake_db.common.proc_load_raw_masters_from_stream(VARCHAR, VARCHAR, VARIANT)
  SET TAG common_db.governance.object_managed_by = 'schemachange'
;
