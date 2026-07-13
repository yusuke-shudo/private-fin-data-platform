# Data Platform Initial Bootstrap Guide (Master Manual)

- 日本語版: [README.ja.md](README.ja.md)

This guide explains the one-time manual bootstrap flow required on each cloud platform before running CI/CD pipelines (Terraform / schemachange / dbt).
Because some configuration values (such as account IDs) are dependent across platforms, **follow the exact order below (AWS -> Snowflake -> GitHub).**

---

## 🚀 Setup Order and Detailed Manuals

Always execute bootstrap in the order below. Each link points to the detailed manual for that platform.

1. [Step 1: AWS bootstrap](./aws/README.md) - Build Terraform S3 backend foundation (S3/Access Point/IAM roles)
2. [Step 2: Snowflake bootstrap](./snowflake/README.md) - Environment/account split (DEV/PRD) and CI/CD objects
3. [Step 3: GitHub environment setup](./github/README.md) - Define environments and map confirmed variables

---

## 🏃‍♂️ Platform Setup Overview

### 1. AWS Initial Setup
* Deploy an S3 backend foundation for Terraform state (`tfstate`) via the provided CloudFormation template (S3 bucket, access point, and CI/CD IAM roles).

### 2. Snowflake Initial Setup
* From the organization account, manually create environment-separated child accounts (DEV/PRD) via SQL.
* Then sign in to each child account and prepare deployment resources including security integration for GitHub Actions OIDC.

### 3. GitHub Actions Initial Setup
* Define GitHub Environments and Variables, then map AWS/Snowflake identifiers obtained in earlier steps.
* Configure strict production protection rules (no self-approval, no admin bypass) to prevent unsafe deployments.

---

## 🏁 Completion Check

When all manual platform steps are complete and required GitHub variables/branch protection are in place, the repository is ready for fully automated deployment via pushes and PR merges to `main`.

If a Terraform workflow fails and leaves a lock file, recover with:

- [.github/workflows/terraform-unlock.yml](../.github/workflows/terraform-unlock.yml)
