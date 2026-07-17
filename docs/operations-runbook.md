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

## 5. Developer Workbench Operation (EC2 + dbt)

This section defines the minimum operation rules for developer workbench instances used for local dbt development.

### 5.1 Provisioning Boundary

- Create and destroy workbench EC2 instances only through `workflow_dispatch` + Terraform.
- Developers do not run Terraform directly for this operation.
- Manual EC2 termination from console should be avoided to prevent Terraform state drift.

### 5.2 Allowed Manual Operations

- Manual stop/start from EC2 console is allowed when IAM policy permits it.
- Terminate/delete must stay in Terraform workflow boundary.

### 5.3 Tag-Based Ownership Model

- Every workbench EC2 must include at least these tags:
   - `Owner` (developer identity)
   - `Environment` (for example `dev`)
   - `Name` (human-readable label)
- Access control should rely on `Owner` tag matching, not only on instance name.

### 5.4 Support Session Model

- Default mode: only owner can access own instance.
- Support mode: temporary cross-owner access is allowed only with explicit approval and audit logging.
- Session Manager logs should be stored for traceability.

### 5.5 Identity Management Boundary

- Human developer user lifecycle management is out of Git scope.
- Repository-managed assets should focus on role/policy boundaries and execution workflow.

### 5.6 Snowflake Developer Execution Boundary (Current Rule)

- Canonical schemas `DATAWAREHOUSE_DB.STAGING` and `DATAWAREHOUSE_DB.CORE` are treated as CI/CD-managed write targets.
- Non-CI/CD developer experiments should run only in personal custom schemas (for example `staging_<owner>`).
- Promotion into canonical schemas must go through pull request + CI/CD execution.
- Personal development schemas are temporary work areas and should be periodically cleaned up.
- This boundary can evolve later, but explicit CI/CD-first protection is the current default.

## 6. Related Documents

- [README.md](../README.md)
- [bootstrap/README.md](../bootstrap/README.md)
- [schemachange/README.md](../schemachange/README.md)
- [dbt](../dbt)