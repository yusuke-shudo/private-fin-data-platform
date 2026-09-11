CREATE TASK IF NOT EXISTS datalake_db.monex_securities.task_load_raw_from_stream_monex_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK datalake_db.monex_securities.task_load_raw_from_stream_monex_securities
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'datalake_db.monex_securities.stream_on_stage_monex_securities'
  )
AS
CALL datalake_db.common.proc_load_raw_from_stream(
  'datalake_db.monex_securities.stream_on_stage_monex_securities',
  'datalake_db.monex_securities.work_from_stream_monex_securities',
  'datalake_db.monex_securities.stage_monex_securities_stream_triggered',
  {
    'all_trade_and_cash_history': {
      'target_table_fqn': 'datalake_db.monex_securities.all_trade_and_cash_history_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter',
      'file_pattern': '.*\\.csv'
    }
  }
)
;
