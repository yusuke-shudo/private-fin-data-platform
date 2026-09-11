CREATE TASK IF NOT EXISTS datalake_db.paypay_bank.task_load_raw_from_stream_paypay_bank
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
AS
EXECUTE IMMEDIATE $$
BEGIN
  -- TASKがSUSPENDしないように、基本的にはCREATE OR ALTERで作成する。
  -- ただし、TAGについてはサポートされていないため、CREATE TASKで作成する。
END
$$
;

CREATE OR ALTER TASK datalake_db.paypay_bank.task_load_raw_from_stream_paypay_bank
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'datalake_db.paypay_bank.stream_on_stage_paypay_bank'
  )
AS
CALL datalake_db.common.proc_load_raw_from_stream(
  'datalake_db.paypay_bank.stream_on_stage_paypay_bank',
  'datalake_db.paypay_bank.work_from_stream_paypay_bank',
  'datalake_db.paypay_bank.stage_paypay_bank_stream_triggered',
  {
    'home_loan_schedule': {
      'target_table_fqn': 'datalake_db.paypay_bank.home_loan_schedule_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter_sjis',
      'file_pattern': '.*\\.csv'
    }
  }
)
;
