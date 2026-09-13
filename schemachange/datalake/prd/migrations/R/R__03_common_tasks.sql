CREATE OR REPLACE TASK datalake_db.common.task_load_raw_0300
  WITH TAG ( common_db.governance.object_managed_by = 'schemachange' )
  SCHEDULE = 'USING CRON 0 3 * * * Asia/Tokyo'
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
AS
CALL datalake_db.common.proc_task_load_raw_0300();

CREATE OR REPLACE TASK datalake_db.common.task_load_csv_to_json_full_refresh
  WITH TAG ( common_db.governance.object_managed_by = 'schemachange' )
  SERVERLESS_TASK_MAX_STATEMENT_SIZE = 'XSMALL'
AS
CALL datalake_db.common.proc_load_csv_to_json_full_refresh(
  'datalake_db.paypay_bank.home_loan_schedule_json',
  'datalake_db.paypay_bank.stage_paypay_bank_stream_triggered/home_loan_schedule/',
  'datalake_db.common.ff_csv_parse_header_sjis',
  '.*\\.csv'
);
