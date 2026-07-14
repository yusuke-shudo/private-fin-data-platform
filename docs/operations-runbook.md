# Environment Setup Guide

- Japanese version: [operations-runbook.ja.md](operations-runbook.ja.md)

This document describes only the initial environment setup procedure.
It is intentionally separate from architecture/design documents.

## 1. Scope

This guide focuses on first-time environment bring-up only.

For design rationale and trade-offs, see [architecture-and-philosophy.md](architecture-and-philosophy.md).

## 2. Responsibility Boundary (Execution View)

- Bootstrap initializes one-time manual prerequisites on each platform.
- Terraform workflows manage fixed platform boundaries (databases/schemas/baseline grants) for ongoing operation.
- schemachange manages versioned SQL migrations where needed after Terraform provisioning.
- dbt manages transformation models in approved schemas.

## 3. First-Time Bring-Up (per environment)

Before starting platform-specific steps, read [bootstrap/README.md](../bootstrap/README.md) as the bootstrap entry point.

### 3.1 Manual Bootstrap + Initial Variables

1. Complete manual bootstrap in this order:
   - [bootstrap/aws/README.md](../bootstrap/aws/README.md)
   - [bootstrap/snowflake/README.md](../bootstrap/snowflake/README.md)
   - [bootstrap/github/README.md](../bootstrap/github/README.md)
2. Register initial variables in the target GitHub Environment:
   - `AWS_ACCOUNT_ID`
   - `PROJECT_PREFIX`
   - `SF_ORGANIZATION_NAME`
   - `SF_ACCOUNT_NAME`

### 3.2 First Terraform Pass

1. Run Terraform workflows once:
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.3 Intermediate Variables

1. Collect outputs and register intermediate variables:
   - `AWS_S3_AP_ALIAS`
   - `SF_USER_ARN`
   - `SF_EXTERNAL_ID`

### 3.4 Second Terraform Pass

1. Re-run Terraform workflows:
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.5 Schemachange Execution

1. Run schemachange workflow:
   - `schemachange-<env>.yml`

Notes:

- `<env>` is `dev` or `prd`.
- Run schemachange only after Terraform integration resources are ready.
- If a Terraform workflow fails and leaves a lock file, recover with [terraform-unlock.yml](../.github/workflows/terraform-unlock.yml).

Directory map for this runbook:

- Workflow definitions: [.github/workflows/](../.github/workflows/)
- Terraform AWS: [terraform/aws/dev/](../terraform/aws/dev/) and [terraform/aws/prd/](../terraform/aws/prd/)
- Terraform Snowflake: [terraform/snowflake/dev/](../terraform/snowflake/dev/) and [terraform/snowflake/prd/](../terraform/snowflake/prd/)
- schemachange lanes: [schemachange/datalake/dev/](../schemachange/datalake/dev/) and [schemachange/datalake/prd/](../schemachange/datalake/prd/)

## 4. Completion Criteria

Treat first-time bring-up as complete when all items below are satisfied for the target environment:

- Manual bootstrap steps are complete: AWS -> Snowflake -> GitHub.
- Initial GitHub Environment variables are registered (`AWS_ACCOUNT_ID`, `PROJECT_PREFIX`, `SF_ORGANIZATION_NAME`, `SF_ACCOUNT_NAME`).
- Terraform AWS and Terraform Snowflake workflows both completed the second run successfully.
- Intermediate variables are registered (`AWS_S3_AP_ALIAS`, `SF_USER_ARN`, `SF_EXTERNAL_ID`).
- schemachange workflow completed after Terraform integration resources became ready.

## 5. Related Documents

- [README.md](../README.md)
- [bootstrap/README.md](../bootstrap/README.md)
- [schemachange/README.md](../schemachange/README.md)
- [dbt](../dbt)