# Schemachange Conventions

Japanese version: [README.ja.md](README.ja.md)

This directory contains schemachange migrations for DATALAKE, DATAWAREHOUSE, and DATAMART.

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
