-- schemachange migration: apply ownership tag to raw tables created by V1.0.0

ALTER TABLE IF EXISTS datalake_db.paypay_bank.home_loan_schedule_raw
  RENAME COLUMN ingest_at TO ingest_at_utc;

ALTER TABLE IF EXISTS datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  RENAME COLUMN ingest_at TO ingest_at_utc;

ALTER TABLE IF EXISTS datalake_db.paypay_bank.home_loan_schedule_raw
  SET TAG common_db.governance.object_managed_by = 'schemachange';

ALTER TABLE IF EXISTS datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw
  SET TAG common_db.governance.object_managed_by = 'schemachange';

ALTER TABLE IF EXISTS datalake_db.schemachange.schemachange_migrations
  SET TAG common_db.governance.object_managed_by = 'schemachange';
