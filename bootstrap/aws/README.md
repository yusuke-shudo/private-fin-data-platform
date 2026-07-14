# AWS Bootstrap Guide (Management Account)

- 日本語版: [README.ja.md](README.ja.md)

This guide explains manual bootstrap tasks performed in the AWS management account to establish the multi-account foundation (AWS Organizations, IAM Identity Center, StackSets).
When this guide says "root user," it refers to the root user of each account (management account and child accounts).

## Workflow in the Management Account

### 1. Authentication and organization foundation

1. Protect the root user
- Sign in with the root user of the management account and enable MFA immediately.

2. Confirm AWS Organizations is enabled
- Open AWS Organizations and verify the organization is active.

3. Enable AWS IAM Identity Center
- Open IAM Identity Center and click Enable.
- Choose the primary data region (for example, `ap-northeast-1`).

4. Create common administrator group
- In `Groups` -> `Create group`, create:
- Group name: `Administrators`
- Description: `Group for users with full administrative access across accounts`

5. Create permission set
- In `Permission sets` -> `Create permission set`, choose predefined `AdministratorAccess`.

6. Create working user
- In `Users` -> `Add user`, create a user (for example, `yusuke_shudo`) and add it to `Administrators`.

7. Assign account access
- In `AWS accounts`, assign group `Administrators` with permission set `AdministratorAccess` to organization accounts.

8. Build OU hierarchy
- In AWS Organizations, create parent OU:
- Name: `Private`
- Description: `OU for personal financial data platform workloads`
- Under `Private`, create two child OUs:
- `Dev`
- `Prd`

### 2. Prepare automated deployment (StackSets)

Note:
- Target child OUs (`Dev` / `Prd`) directly.
- Do not target parent OU `Private`, otherwise dev settings may be deployed into production accounts.

What this StackSet applies (summary):
- GitHub OIDC provider and IAM roles for CI/CD (`github-actions-tfstate-access-role`, `github-actions-resource-creation-role`)
- Terraform state S3 bucket (`<ProjectPrefix>-<env>-tfstate`) with versioning, object lock, encryption, and public-access block
- S3 Access Point and restrictive bucket/access-point policies (access-point-only path, TLS 1.2+ enforcement)

For template-level details (resources, parameters, outputs), see:
- [templates/README.md](templates/README.md)

1. Deploy StackSet for Dev
- Open `CloudFormation` -> `StackSets` -> `Create StackSet`.
- Template: `bootstrap/aws/templates/fin-data-tfstate-base.yaml`
- StackSet name: `fin-data-tfstate-base-dev`
- Parameter `Environment`: `dev`
- Target: child OU ID for `Dev`
- Region: primary region (for example, `ap-northeast-1`)
- Auto Deployment: `Enabled`
- Completion check: confirm Stack instances for Dev target accounts are in `CURRENT` status.

2. Deploy StackSet for Prd
- Create another StackSet with:
- Same template file
- StackSet name: `fin-data-tfstate-base-prd`
- Parameter `Environment`: `prd`
- Target: child OU ID for `Prd`
- Region: primary region
- Auto Deployment: `Enabled`
- Completion check: confirm Stack instances for Prd target accounts are in `CURRENT` status.

### 3. Create and initialize child accounts

Run the following for both DEV and PRD.

#### 3-1. DEV setup

1. Create AWS account
- In AWS Organizations, `Add an AWS account` -> `Create an AWS account`.
- Account name: `fin-data-platform-dev`
- Email: `xxxxxx+aws-fin-data-platform-dev@yourdomain.com`

2. Protect root user as fallback
- Set root password via sign-in page (`Forgot password`).
- Sign in as root and enable MFA in IAM dashboard.
- Store MFA secret/QR safely in a password manager.
- Sign out.

3. Move account to target OU
- In AWS Organizations, move account `fin-data-platform-dev` into child OU `Private/Dev`.
- This triggers StackSets auto deployment to create dev resources such as S3 bucket and IAM role.

#### 3-2. PRD setup

1. Create AWS account
- In AWS Organizations, `Add an AWS account` -> `Create an AWS account`.
- Account name: `fin-data-platform-prd`
- Email: `xxxxxx+aws-fin-data-platform-prd@yourdomain.com`

2. Protect root user
- Same as DEV: set root password and enable MFA, then sign out.

3. Move account to target OU
- Move `fin-data-platform-prd` into child OU `Private/Prd`.
- StackSets auto deployment runs and creates production resources (including S3 object lock settings where configured).

### 4. Lock recovery for Terraform workflows

If a Terraform workflow fails and leaves a lock file behind, use the unlock workflow instead of manually signing in to AWS and deleting lock artifacts.

- [.github/workflows/terraform-unlock.yml](../../.github/workflows/terraform-unlock.yml)
