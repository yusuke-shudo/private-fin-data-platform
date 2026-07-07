# dbt - Data Transformation Layer

dbt による Bronze → Silver → Gold の変換層を管理します。

## Architecture

```
【Bronze (datalake_db.raw / datalake_db.{source})】
  ↓ (schemachange: raw data ingestion)
  
【Silver (datawarehouse_db.staging / datawarehouse_db.core)】
  ↓ (dbt: staging models, source cleanup)
  
【Gold (datamart_db.mart)】
  ↓ (dbt: business-ready tables)
```

## dbt Development Conventions

### 1. SQL スタイル

**CTE パターン（dbt best practice に準拠）:**

```sql
{{
  config(...)
}}

with source_data as (
  select * from {{ source('schema', 'table') }}
),
renamed_data as (
  select
    col1  as renamed_col1,
    col2  as renamed_col2
  from source_data
),
final as (
  select * from renamed_data
)
select * from final
```

**ルール:**
- 最初の CTE は必ず `{{ source() }}` 使用（Bronze から取得）、以降は `{{ ref() }}` で他の model 参照
- 最後は単一の `SELECT * FROM xxx` で統一（CTE 名は任意）
- CTE 名: 意味のある名前（source_data, renamed_data, aggregated など）
- インデント: スペース 2 個
- カラムアライン: **最小 2 spaces** 以上
- **予約語: 大文字（SELECT, FROM, WHERE, AS, WITH など）、それ以外: 小文字**
- Trailing semicolon: 末尾に `;` 不要（dbt が自動追加）

**例:**
```sql
select
  col_name1     as  column_name1,
  col_name2     as  column_name2
from source_data
```

### 2. ディレクトリ構造と命名規則

**ディレクトリ:** `models/{layer}/{source}_{table}/`

```
models/
  ├── staging/
  │   ├── paypay_bank_home_loan_schedule/
  │   │   ├── stg_paypay_bank_home_loan_schedule__schedule.sql
  │   │   ├── _paypay_bank_home_loan_schedule__sources.yml
  │   │   └── _paypay_bank_home_loan_schedule__models.yml
  │   │
  │   └── sbi_securities_sbi_tokutei_profit_loss_report/
  │       ├── stg_sbi_securities_sbi_tokutei_profit_loss_report__yearly_summary.sql
  │       ├── stg_sbi_securities_sbi_tokutei_profit_loss_report__trades.sql
  │       ├── stg_sbi_securities_sbi_tokutei_profit_loss_report__dividends.sql
  │       ├── _sbi_securities_sbi_tokutei_profit_loss_report__sources.yml
  │       └── _sbi_securities_sbi_tokutei_profit_loss_report__models.yml
  │
  ├── core/
  │   ├── {source}_{table}/
  │   │   ├── fct_{source}_{table}.sql
  │   │   └── _fct_{source}_{table}__models.yml
  │
  └── mart/
      └── {business_domain}/
          ├── dim_*.sql
          ├── fct_*.sql
          └── schema.yml
```

**ファイル命名:**
- Model ファイル: `stg_/{source}__{entity}.sql` （staging）
  - `source` = directory 名と一致
  - `entity` = テーブルの業務区分
  - 複数単語は `__` で明示的に区切る
- YAML ファイル: `__{name}__sources.yml`, `__{name}__models.yml`
  - sources / models を分離
- ディレクトリ名: `{schema}_{table}`（機械的、小文字）

### 3. YAML ファイル構成

**sources.yml:**
```yaml
version: 2

sources:
  - name: source_name
    description: Source description
    database: DATALAKE_DB
    schema: schema_name
    tables:
      - name: table_name
        description: Table description (include SJIS encoding if applicable)
        meta:
          primary_key: [col1, col2]
        columns:
          - name: column_name
            description: Column description
            tests:
              - not_null
```

**models.yml:**
```yaml
version: 2

models:
  - name: stg_source__entity
    description: Staging model for {source} {entity} (Bronze → Silver)
    tests:
      - dbt_utils.recency:
          datepart: day
          field: created_at
          interval: 3
    columns:
      - name: column_name
        description: Column description
        tests:
          - not_null
          - unique
```

**ルール:**
- source table の meta に `primary_key` を記載（ドキュメント化）
- model には column 単位で `data_type` と `tests` を記載
- description は実務的な内容（スキーマ構造は README / schemachange に記載）

### 4. Tests

**Source-level tests:**
```yaml
columns:
  - name: file_path
    tests:
      - not_null
```

**Model-level tests:**
```yaml
models:
  - name: stg_xxx
    tests:
      - dbt_utils.recency:
          datepart: day
          field: created_at
          interval: 3
```

### 5. 環境分離戦略

**GitHub Flow + profiles.yml:**

```
main branch (prd profile)
  ↓ dbt run --profiles-dir profiles -t prd

feature branch (dev profile)
  ↓ dbt run --profiles-dir profiles -t dev
```

**profiles.yml:**
- `profiles/dev.yml`: dev schema
- `profiles/prd.yml`: prd schema
- 同じ SQL ファイル、異なる target schema

### 6. dbt_project.yml 設定

**Layer-level materialization:**
```yaml
models:
  private_fin_data_platform:
    staging:
      +materialized: view
      +database: DATAWAREHOUSE_DB
      +schema: STAGING
    
    core:
      +materialized: table
      +database: DATAWAREHOUSE_DB
      +schema: CORE
      +table_format: iceberg  # Iceberg format for Silver layer
    
    mart:
      +materialized: table
      +database: DATAMART_DB
      +schema: MART
```

### 7. Source データの扱い

**原則:**
- Bronze: 生データそのまま保存（`raw_text VARCHAR`）
- Silver (dbt staging): `raw_text` から parse → clean
- Golden Gate: 複数 source 統合（複数 Silver をJOIN）

**禁止:**
- ファイル単位で異なる `raw_payload` 形式を使用
- 環境毎に異なる schema 定義

### 8. Constraint の使用

**Sources**: `meta.primary_key` でメタデータ化

```yaml
tables:
  - name: table_name
    meta:
      primary_key: [col1, col2]
```

**Models** (table/incremental のみ): `constraints` で構造化
- 後段で実装予定（core/mart layer）
- Snowflake では NOT ENFORCED だが、catalog tools 連携用

### 9. タグと Tags

**推奨:**
- `tag: [daily, weekly, monthly]` - 実行頻度
- `tag: [pii, confidential]` - セキュリティ分類
- `tag: [reporting]` - ユース・ケース

### 10. チェックリスト

新規 staging model 作成時：

- [ ] ディレクトリ名: `{schema}_{table}` （機械的）
- [ ] Model ファイル: `stg_{directory}__{entity}.sql`
- [ ] SQL: source_data → renamed_data → final 構造
- [ ] sources.yml: primary_key 定義、column tests
- [ ] models.yml: data_type, description, tests
- [ ] dbt_project.yml: layer materialization 設定
- [ ] profiles.yml: dev/prd target 設定
- [ ] `dbt parse` で構文チェック
- [ ] `dbt test` で test 実行
- [ ] `dbt run` で実行確認

---

## Development Commands

```bash
# Parse（構文チェック）
dbt parse

# Test（source + model）
dbt test

# Run（dev環境）
dbt run --profiles-dir profiles -t dev

# Run（prd環境）
dbt run --profiles-dir profiles -t prd

# Specific model
dbt run -s stg_paypay_bank_home_loan_schedule__schedule
```

## References

- dbt Best Practices: https://docs.getdbt.com/best-practices
- Snowflake dbt-adapter: https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup
