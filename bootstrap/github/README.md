# GitHub Bootstrap Guide

- 日本語版: [README.ja.md](README.ja.md)

This guide describes manual GitHub setup after creating repository `private-fin-data-platform`: local sync defaults, general settings, branch protection rulesets, and platform environments/variables.

## GitHub bootstrap flow

### 1. Base settings and local sync

1. Align local default branch name
```bash
git config --global init.defaultBranch main
```
- Prevents local repositories from defaulting to `master` and keeps consistency with GitHub `main`.

2. Confirm repository visibility
- In `Settings` -> `General` -> `Danger Zone`, confirm repository visibility is `Public`.
- On GitHub Free plans, some protection features are available for public repositories.

3. Restrict merge methods
- In `Settings` -> `General` -> `Pull Requests`:
- Disable `Allow merge commits`
- Enable `Allow squash merging`
- Enable `Allow rebase merging`

4. Auto-delete merged branches
- In `General`, enable `Automatically delete head branches`.

### 2. Configure branch protection (Rulesets)

1. Create new ruleset
- `Settings` -> `Rules` -> `Rulesets` -> `New ruleset`.

2. Basic setup
- Ruleset name: `Protect main`
- Enforcement status: `Active`
- Keep bypass list empty to prevent privileged direct merges.

3. Target branch
- Add include target by name: `main`.

4. Enable branch rules
- Enable `Require a pull request before merging`
- Required approvals: `1`
- Enable stale approval dismissal
- Enable `Require review from Code Owners`
- Enable `Require conversation resolution before merging`
- Allowed merge methods:
- Merge commit: disabled
- Squash: enabled
- Rebase: enabled
- Save with `Create`.

### 3. Create Environments and Variables

Why 4 environments:
- Snowflake OIDC subject constraints can require unique environment-role combinations.
- Define separate environments for infra and data workloads in dev/prd.

1. Create dev environments and variables
- Create:
- `dev-infra` (Terraform infra)
- `dev-data` (dbt/data)
- In both, register:
- `AWS_ACCOUNT_ID` = [dev AWS account ID]
- `PROJECT_PREFIX` = `yskshd-fin-data`
- `SF_ORGANIZATION_NAME` = [Snowflake org]
- `SF_ACCOUNT_NAME` = [dev Snowflake account]

2. Create prd environments and protection rules
- Create:
- `prd-infra`
- `prd-data`
- In both, set deployment protection:
- Enable `Required reviewers`
- Add 2+ approvers (or team)
- Enable `Prevent self-review`
- Disable `Allow administrators to bypass configured protection rules`
- Register production values for the same 4 variables.

### 4. Supplement: single-person two-account validation flow

With strict rules (CODEOWNERS approval required, self-review prevention, no admin bypass), full end-to-end testing by one person requires a second account.

#### 4-1. Preparation

1. Invite collaborator account
- Add your secondary account in `Settings` -> `Collaborators`.
- Sign in with secondary account and accept invitation.

2. Add required reviewers
- Add the secondary account as required reviewer in `prd-infra` and `prd-data`.

3. Add CODEOWNERS
- Place `CODEOWNERS` at repository root (or `.github/`) with both accounts listed.

```text
# AWS code owners
/terraform/aws/            @[main-account] @[secondary-account]

# Snowflake code owners
/terraform/snowflake/      @[main-account] @[secondary-account]
```

#### 4-2. Validation lifecycle

| Step | Account | Action | Trigger |
| :--- | :---: | :--- | :--- |
| 1. Create PR | Main | Create PR from topic branch to `main` | Plan runs |
| 2. Approve code | Secondary | Approve PR review | CODEOWNERS requirement satisfied |
| 3. Merge PR | Main | Squash/rebase merge | Dev apply runs |
| 4. Wait for prd gate | - | Workflow pauses at deployment review | Pipeline paused |
| 5. Approve prd deploy | Secondary | Approve `Review deployments` for prd env | Prd apply runs |

Note:
- If the main account tries to approve production deployment, `Prevent self-review` blocks it.
