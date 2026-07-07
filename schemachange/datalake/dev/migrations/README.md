# DATALAKE Migrations

schemachange による DATALAKE_DB スキーマ定義。

## Current Schema

### home_loan_schedule_raw
```sql
CREATE TABLE datalake_db.paypay_bank.home_loan_schedule_raw (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  raw_text       VARCHAR        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### home_loan_schedule_json
```sql
CREATE TABLE datalake_db.paypay_bank.home_loan_schedule_json (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  data_json      VARIANT        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_json PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_tokutei_profit_loss_report_raw
```sql
CREATE TABLE datalake_db.sbi_securities.sbi_tokutei_profit_loss_report_raw (
  ingest_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path      VARCHAR        NOT NULL,
  line_number    NUMBER         NOT NULL,
  raw_text       VARCHAR        NOT NULL,
  CONSTRAINT pk_sbi_tokutei_profit_loss_report_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```
