# Environment Setup Guide

- Japanese version: [operations-runbook.ja.md](operations-runbook.ja.md)

This document describes only the initial environment setup procedure.
It is intentionally separate from architecture/design documents.

## 1. Scope

This guide focuses on first-time environment bring-up only.

For design rationale and trade-offs, see [architecture-and-philosophy.md](architecture-and-philosophy.md).

## 2. First-Time Bring-Up (per environment)

Follow this order for a new environment:

1. Complete manual bootstrap in this order:
   - [bootstrap/aws/README.md](../bootstrap/aws/README.md)
   - [bootstrap/snowflake/README.md](../bootstrap/snowflake/README.md)
   - [bootstrap/github/README.md](../bootstrap/github/README.md)
2. Register initial variables in the target GitHub Environment:
   - `AWS_ACCOUNT_ID`
   - `PROJECT_PREFIX`
   - `SF_ORGANIZATION_NAME`
   - `SF_ACCOUNT_NAME`
3. Run Terraform workflows once:
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`
4. Collect outputs and register intermediate variables:
   - `AWS_S3_AP_ALIAS`
   - `SF_USER_ARN`
   - `SF_EXTERNAL_ID`
5. Re-run Terraform workflows:
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`
6. Run schemachange workflow:
   - `schemachange-<env>.yml`

Notes:

- `<env>` is `dev` or `prd`.
- Run schemachange only after Terraform integration resources are ready.

## 3. Related Documents

- [README.md](../README.md)
- [bootstrap/README.md](../bootstrap/README.md)
- [schemachange/README.md](../schemachange/README.md)
- [dbt](../dbt)