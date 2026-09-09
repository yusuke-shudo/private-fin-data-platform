CREATE OR ALTER TASK datalake_db.paypay_bank.task_paypay_bank_masters_refresh
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  TARGET_COMPLETION_INTERVAL = '1 MINUTES'
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'datalake_db.paypay_bank.stream_paypay_bank_masters_direct_dir'
  )
AS
CALL datalake_db.common.proc_load_raw_masters_from_stream(
  'datalake_db.paypay_bank.stream_paypay_bank_masters_direct_dir',
  'datalake_db.paypay_bank.work_stream_paypay_bank_masters_direct_dir',
  'datalake_db.paypay_bank.stage_paypay_bank_masters_direct_dir',
  {
    'home_loan_schedule': {
      'target_table_fqn': 'datalake_db.paypay_bank.home_loan_schedule_raw',
      'file_format_fqn': 'datalake_db.common.ff_nodelimiter_sjis'
    }
  }
)
;
