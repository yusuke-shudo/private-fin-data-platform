# DATALAKE Migrations

schemachange による DATALAKE_DB スキーマ定義。

## Current Schema (Final State after all migrations)

### paypay_bank.home_loan_schedule_raw
```sql
CREATE TABLE datalake_db.paypay_bank.home_loan_schedule_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### paypay_bank.home_loan_schedule_json
```sql
CREATE TABLE datalake_db.paypay_bank.home_loan_schedule_json (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  data_json        VARIANT        NOT NULL,
  CONSTRAINT pk_home_loan_schedule_json PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### orico_credit.home_reform_loan_schedule_raw
```sql
CREATE TABLE datalake_db.orico_credit.home_reform_loan_schedule_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_home_reform_loan_schedule_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_securities.domestic_trade_history_raw
```sql
CREATE TABLE datalake_db.sbi_securities.domestic_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_domestic_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_securities.foreign_trade_history_raw
```sql
CREATE TABLE datalake_db.sbi_securities.foreign_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_foreign_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_securities.futures_options_trade_history_raw
```sql
CREATE TABLE datalake_db.sbi_securities.futures_options_trade_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_futures_options_trade_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_securities.tokutei_profit_loss_report_raw
```sql
CREATE TABLE datalake_db.sbi_securities.tokutei_profit_loss_report_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_tokutei_profit_loss_report_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### monex_securities.all_trade_and_cash_history_raw
```sql
CREATE TABLE datalake_db.monex_securities.all_trade_and_cash_history_raw (
  ingested_at_utc  TIMESTAMP_NTZ  NOT NULL,
  file_path        VARCHAR        NOT NULL,
  line_number      NUMBER         NOT NULL,
  raw_text         VARCHAR        NOT NULL,
  CONSTRAINT pk_all_trade_and_cash_history_raw PRIMARY KEY (file_path, line_number) RELY
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

## Directory Stage Streams and Work Tables

Directory table の変更を追跡する stream。stream は offset を持つ stateful なオブジェクトのため、
`R__` ではなく versioned migration で作成する。
また、stream から change data を読み取るための work テーブル（TRANSIENT TABLE）も同時に作成される。

### paypay_bank.stream_on_stage_paypay_bank
```sql
CREATE STREAM datalake_db.paypay_bank.stream_on_stage_paypay_bank
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.paypay_bank.stage_paypay_bank_stream_triggered
;
```

### paypay_bank.work_from_stream_paypay_bank
```sql
CREATE TRANSIENT TABLE datalake_db.paypay_bank.work_from_stream_paypay_bank (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### orico_credit.stream_on_stage_orico_credit
```sql
CREATE STREAM datalake_db.orico_credit.stream_on_stage_orico_credit
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.orico_credit.stage_orico_credit_stream_triggered
;
```

### orico_credit.work_from_stream_orico_credit
```sql
CREATE TRANSIENT TABLE datalake_db.orico_credit.work_from_stream_orico_credit (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### sbi_securities.stream_on_stage_sbi_securities
```sql
CREATE STREAM datalake_db.sbi_securities.stream_on_stage_sbi_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.sbi_securities.stage_sbi_securities_stream_triggered
;
```

### sbi_securities.work_from_stream_sbi_securities
```sql
CREATE TRANSIENT TABLE datalake_db.sbi_securities.work_from_stream_sbi_securities (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```

### monex_securities.stream_on_stage_monex_securities
```sql
CREATE STREAM datalake_db.monex_securities.stream_on_stage_monex_securities
  WITH TAG (common_db.governance.object_managed_by = 'schemachange')
  ON STAGE datalake_db.monex_securities.stage_monex_securities_stream_triggered
;
```

### monex_securities.work_from_stream_monex_securities
```sql
CREATE TRANSIENT TABLE datalake_db.monex_securities.work_from_stream_monex_securities (
  relative_path  VARCHAR,
  action         VARCHAR,
  last_modified  TIMESTAMP_TZ
)
WITH TAG (common_db.governance.object_managed_by = 'schemachange')
;
```
