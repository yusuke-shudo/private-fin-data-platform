CREATE TASK IF NOT EXISTS datalake_db.sbi_securities.task_load_raw_from_stream_sbi_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK datalake_db.sbi_securities.task_load_raw_from_stream_sbi_securities
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'datalake_db.sbi_securities.stream_on_stage_sbi_securities'
  )
AS
CALL datalake_db.common.proc_load_raw_from_stream(
  'datalake_db.sbi_securities.stream_on_stage_sbi_securities',
  'datalake_db.sbi_securities.work_from_stream_sbi_securities',
  'datalake_db.sbi_securities.stage_sbi_securities_stream_triggered',
  {
    'futures_options_trade_history': {
      'target_table_fqn': 'datalake_db.sbi_securities.futures_options_trade_history_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter_sjis',
      'file_pattern': '.*\\.csv'
    },
    'tokutei_profit_loss_report': {
      'target_table_fqn': 'datalake_db.sbi_securities.tokutei_profit_loss_report_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter_sjis',
      'file_pattern': '.*\\.csv'
    }
  }
)
;
