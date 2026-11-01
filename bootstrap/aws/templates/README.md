# AWS Bootstrap Templates

- Japanese version: [README.ja.md](README.ja.md)

This directory contains CloudFormation templates used by StackSets during AWS bootstrap.

## Templates

### fin-data-tfstate-base.yaml

Purpose:
- Create baseline resources required for Terraform backend and CI/CD access in each target account (`dev` / `prd`).

Main resources:
- IAM OIDC provider for GitHub Actions
- IAM role for Terraform state access: `github-actions-tfstate-access-role`
- IAM role for resource creation: `github-actions-resource-creation-role`
- S3 bucket for Terraform state: `<ProjectPrefix>-<env>-tfstate`
- S3 Access Point for controlled state access
- S3 bucket policy and access-point policy enforcing restricted access and TLS 1.2+

This template is for initial bootstrap. It creates account-wide IAM resources and creates the state bucket and Access Point in the Stack instance's Region.

Parameters:
- `Environment`: `dev` or `prd`
- `GitHubOwner`: GitHub org/user name
- `GitHubRepository`: GitHub repository name
- `ProjectPrefix`: prefix for global S3 naming uniqueness

Outputs:
- `GitHubActionsRoleArn`
- `GitHubActionsResourceCreationRoleArn`
- `S3BucketName`
- `S3AccessPointArn`

### fin-data-tfstate-regional.yaml

Purpose:
- Create a Terraform state backend in an additional Region using the existing account-wide IAM role.

Main resources:
- Terraform state S3 bucket in the account regional namespace. AWS appends the account ID, Region, and `-an` suffix.
- S3 Access Point granting access to the existing `github-actions-tfstate-access-role` and `github-actions-resource-creation-role`
- Policies enforcing Access Point access, TLS 1.2+, and public-access blocking

This template does not create an IAM OIDC provider or IAM roles. The bucket and Access Point are created in the Stack instance's Region.

Parameters:
- `Environment`: `dev` or `prd`
- `ProjectPrefix`: prefix for global S3 naming uniqueness
- `GitHubActionsTfstateAccessRoleName`: name of the existing IAM role to authorize
- `GitHubActionsResourceCreationRoleName`: name of the existing resource-creation role authorized through the Access Point

Outputs:
- `S3BucketName`
- `S3AccessPointArn`

## Environment Differences

- Resource names are environment-scoped via `Environment` and `ProjectPrefix`.
- Security controls are shared by design across both environments.

## Change Notes

- Treat IAM role names and output keys as contract surfaces consumed by CI/CD and Terraform.
- Review changes to trust policies and bucket policies carefully before applying to `prd`.
