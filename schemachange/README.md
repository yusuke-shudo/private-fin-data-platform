# Schemachange Conventions

- 日本語版: [README.ja.md](README.ja.md)

This directory contains schemachange migrations for DATALAKE, DATAWAREHOUSE, and DATAMART.

## Current Lane Status

- DATALAKE: active
- DATAMART: reserved lane (currently empty)
- DATAWAREHOUSE: reserved lane (currently empty)

Current boundary:
- Fixed DATAWAREHOUSE schemas (`SCHEMACHANGE`, `STAGING`, `CORE`) are managed by Terraform.
- DATAMART `SCHEMACHANGE` schema is managed by Terraform.
- The `schemachange/datawarehouse` and `schemachange/datamart` paths are intentionally kept for future SQL objects that are better managed by schemachange.

## TASK Policy

- TASK definitions for active datalake pipelines are managed in `schemachange/datalake/*/migrations/R/`.
- Do not auto-resume TASKs after definition changes. Keep resume as an explicit operational action to avoid unintentionally starting paused workloads.

## Stream and Work Table Policy (v1.0.9+)

- Directory table streams (`stream_on_stage_*`) track file changes in S3 landing zones.
- Stream records are entirely extracted to work tables (transient tables) before processing. This decouples stream consumption from record-level processing and enables consistent error handling and retries.
- Stream-triggered tasks (`WHEN SYSTEM$STREAM_HAS_DATA(...)`) auto-execute when new files are detected.
- Tasks include `SUSPEND_TASK_AFTER_NUM_FAILURES = 3` to prevent infinite retry loops. Work table records remaining after task suspension are reprocessed on the next execution.
- Stream definitions, work table schemas, and task definitions are all managed in versioned migrations (V1.0.9+). Do not use repeatable (R) migrations for objects that hold data.

## SQL Style

Apply the following formatting rule to column definitions in migration SQL:

- Keep at least 2 spaces between column name and data type.
- Keep at least 2 spaces between data type and NOT NULL.

Example:

```sql
payment_date           DATE          NOT NULL,
extra_interest_amount  NUMBER,
created_at             TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
```

## Notes

- sqlfluff is useful for general SQL quality checks, but this visual alignment rule may need manual review.
- Keep formatting consistent across all migration files.
