# Data Platform Initial Bootstrap Guide (Master Manual)

- 日本語版: [README.ja.md](README.ja.md)

This guide explains the one-time manual bootstrap flow required on each cloud platform before running CI/CD pipelines (Terraform / schemachange / dbt).
Because some configuration values (such as account IDs) are dependent across platforms, **follow the exact order below (AWS -> Snowflake -> GitHub).**

---

## 🚀 Setup Order and Detailed Manuals

Always execute bootstrap in the order below. Each link points to the detailed manual for that platform.

1. [Step 1: AWS bootstrap](./aws/README.md) - Build Terraform S3 backend foundation (S3/Access Point/IAM roles)
2. [Step 2: Snowflake bootstrap](./snowflake/README.md) - Environment/account split (DEV/PRD) and CI/CD objects
3. [Step 3: GitHub environment setup](./github/README.md) - Define GitHub Environments and baseline variables

---

## 🏃‍♂️ Platform Setup Overview

### 1. AWS Initial Setup
* Deploy an S3 backend foundation for Terraform state (`tfstate`) via the provided CloudFormation template (S3 bucket, access point, and CI/CD IAM roles).

### 2. Snowflake Initial Setup
* From the organization account, manually create environment-separated child accounts (DEV/PRD) via SQL.
* Then sign in to each child account and prepare deployment resources including security integration for GitHub Actions OIDC.

### 3. GitHub Actions Initial Setup
* Define GitHub Environments and baseline Variables.
* For detailed variable registration flow and timing, see [docs/operations-runbook.md](../docs/operations-runbook.md).
* Configure strict production protection rules (no self-approval, no admin bypass) to prevent unsafe deployments.

---

## 🏁 Completion Check

When the manual bootstrap steps (AWS -> Snowflake -> GitHub) are complete, continue with the execution flow in [docs/operations-runbook.md](../docs/operations-runbook.md).

First-time bring-up should be judged complete using the runbook completion criteria.
