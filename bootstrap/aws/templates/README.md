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

## Environment Differences

- Resource names are environment-scoped via `Environment` and `ProjectPrefix`.
- Security controls are shared by design across both environments.

## Change Notes

- Treat IAM role names and output keys as contract surfaces consumed by CI/CD and Terraform.
- Review changes to trust policies and bucket policies carefully before applying to `prd`.
