CREATE TASK IF NOT EXISTS datalake_db.paypay_bank.task_paypay_bank_masters_refresh
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  TARGET_COMPLETION_INTERVAL = '1 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA(
    'DATALAKE_DB.PAYPAY_BANK.STREAM_PAYPAY_BANK_MASTERS_DIRECT_DIR'
  )
AS
CALL datalake_db.common.proc_load_raw_masters_from_stream(
  'DATALAKE_DB.PAYPAY_BANK.STREAM_PAYPAY_BANK_MASTERS_DIRECT_DIR',
  'DATALAKE_DB.PAYPAY_BANK.STAGE_PAYPAY_BANK_MASTERS_DIRECT_DIR',
  PARSE_JSON($${
    "home_loan_schedule": {
      "path_prefix": "home_loan_schedule/",
      "target_table": "DATALAKE_DB.PAYPAY_BANK.HOME_LOAN_SCHEDULE_RAW",
      "file_format": "DATALAKE_DB.COMMON.FF_NODELIMITER_SJIS"
    }
  }$$)
)
;