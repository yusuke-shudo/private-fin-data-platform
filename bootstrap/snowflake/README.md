# Snowflake Bootstrap Guide

- 日本語版: [README.ja.md](README.ja.md)

This guide describes manual Snowflake setup steps that must be completed in Snowsight before CI/CD (GitHub Actions) can run.

What this bootstrap configures (summary):
- Organization account baseline settings and child account creation (`_dev` / `_prd`)
- Child-account CI/CD warehouses, roles, account-level grants, and OIDC service users for GitHub Actions
- Baseline task-execution privileges for `cicd_data_engineer_role` (object-level grants are applied after DB/schema provisioning)

## Manual bootstrap flow

### 1. Work in the Organization account

1. Sign in to org admin account
- Sign in to the organization management (parent) account.

2. Run account creation script
- Open worksheet `01_org_admin_setup.sql`.
- Required roles available to your session: `ACCOUNTADMIN`, `SYSADMIN`, `ORGADMIN`.
- Replace password placeholders with secure values, then execute all SQL.
- This creates child accounts for separated environments (`_dev` and `_prd`).

### 2. Work in child accounts (for both DEV and PRD)

For each child account (DEV and PRD), run the following steps independently.

1. Prepare worksheet
- Open `Worksheets` in the target child account.
- Required roles available to your session: `SYSADMIN`, `SECURITYADMIN`, `ACCOUNTADMIN`, `USERADMIN`.
- Copy and paste `02_child_account_cicd_setup.sql`.

2. Update environment-specific value
- In the script, replace `<ENVIRONMENT_NAME>` in `SUBJECT` based on current account:
- `dev` when in DEV account
- `prd` when in PRD account

3. Execute CI/CD setup SQL
- Execute all SQL in the worksheet after edits.
- This prepares base deployment objects including dedicated users and roles required by downstream Terraform automation.

### 3. Completion checks

After running both scripts, confirm the following:

- Org account: child accounts for `dev` and `prd` are created and visible.
- Each child account: warehouses `cicd_infra_wh` and `cicd_data_wh` exist.
- Each child account: roles `cicd_infra_engineer_role` and `cicd_data_engineer_role` exist.
- Each child account: users `cicd_infra_engineer_user` and `cicd_data_engineer_user` exist with expected OIDC `SUBJECT` values.
