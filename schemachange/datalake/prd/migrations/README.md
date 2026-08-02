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
