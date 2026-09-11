CREATE TASK IF NOT EXISTS datalake_db.orico_credit.task_load_raw_from_stream_orico_credit
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK datalake_db.orico_credit.task_load_raw_from_stream_orico_credit
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'datalake_db.orico_credit.stream_on_stage_orico_credit'
  )
AS
CALL datalake_db.common.proc_load_raw_from_stream(
  'datalake_db.orico_credit.stream_on_stage_orico_credit',
  'datalake_db.orico_credit.work_from_stream_orico_credit',
  'datalake_db.orico_credit.stage_orico_credit_stream_triggered',
  {
    'home_loan_schedule': {
      'target_table_fqn': 'datalake_db.orico_credit.home_loan_schedule_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter',
      'file_pattern': '.*\\.csv'
    }
  }
)
;
