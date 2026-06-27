# private-fin-data-platform

- 日本語版: [README.ja.md](README.ja.md)

This monorepo centrally manages infrastructure and data-platform-related objects built on AWS and Snowflake using Terraform.

---

## 📘 0. Design Philosophy

If you want to understand the architecture philosophy and design principles first, refer to:

- [Architecture and Design Philosophy](docs/architecture-and-philosophy.md)
- [Architecture and Philosophy (Japanese)](docs/architecture-and-philosophy.ja.md)

## 🖼️ Architecture Diagram

- View (browser): [Platform Overview (SVG)](docs/diagrams/platform-overview.svg)
- Edit source: [Platform Overview (draw.io)](docs/diagrams/platform-overview.drawio)

---

## 🗺️ 1. Directory Structure

This repository is composed of three main directories:

- `bootstrap`: one-time initial setup
- `schemachange`: database migration management
- `terraform`: continuous infrastructure management

```text
├── .github/workflows/       # CI/CD workflows (by environment/provider)
│   ├── tf-aws-dev.yml
│   ├── tf-aws-prd.yml
│   ├── tf-snowflake-dev.yml
│   ├── tf-snowflake-prd.yml
│   └── tf-unlock.yml        # State lock release
├── CODEOWNERS               # Code owner definitions for approvals
├── bootstrap/               # 1. Initial setup phase
│   ├── aws/                 # S3 backend, CloudFormation templates, etc.
│   ├── github/              # Initial environment variable setup and rules
│   └── snowflake/           # Org admin / CI-CD user bootstrap SQL
├── schemachange/            # schemachange assets (dev/prd migrations)
└── terraform/               # 2. Continuous management phase
   ├── aws/                 # AWS resources (network, IAM, S3, etc.)
    │   ├── dev/
    │   └── prd/
   └── snowflake/           # Snowflake resources (integrations, DB, roles)
        ├── dev/
        └── prd/
```

---

## ⚙️ 2. Components and Environments

Workflows and Terraform execution directories are fully separated by provider (target cloud) and environment (dev/prd).

| Directory | Target Platform | Environments | Main Files |
| :--- | :--- | :--- | :--- |
| **`terraform/aws/`** | Amazon Web Services | `dev` / `prd` | main, providers, backend, variables, outputs.tf |
| **`terraform/snowflake/`** | Snowflake | `dev` / `prd` | main, providers, backend, variables, outputs, integration.tf |

> 💡 **Symmetry Between Environments**
> The `dev` and `prd` directory structures and core configuration files (`variables.tf`, etc.) are intentionally symmetrical. Environment-specific differences are controlled via GitHub Environment variables.

---

## 🔐 3. GitHub Environment Settings

The following environments are defined in **Settings > Environments** on GitHub and used to control deployment targets and permissions.

* **`dev-infra` / `prd-infra`**: Primarily for base infrastructure on `terraform/aws/`
* **`dev-data` / `prd-data`**: Primarily for `terraform/snowflake/`, and for future data-object/ELT work via **schemachange / dbt**

---

## 🚀 4. Bootstrap-to-Terraform Execution Flow

When setting up a new environment, use the following sequence to resolve dependency order (chicken-and-egg problems) and execute bootstrap plus workflow setup in two stages.

### 🔄 Total 7 Managed Variables
* **Variables registered during bootstrap (4)**: `AWS_ACCOUNT_ID`, `PROJECT_PREFIX`, `SF_ORGANIZATION_NAME`, `SF_ACCOUNT_NAME`
* **Variables added manually in the middle (3)**: `AWS_S3_AP_ALIAS`, `SF_USER_ARN`, `SF_EXTERNAL_ID`

### 📋 Setup Steps

1. **Run bootstrap and register the initial 4 variables**
   * Execute steps under `bootstrap/` in order (CloudFormation deployment, Snowflake initial SQL, etc.).
   * Register the confirmed initial 4 variables in the target GitHub environment (e.g., `dev-infra`).
2. **First workflow run (to determine dynamic values)**
   * Run the target infrastructure workflow once (e.g., `tf-aws-dev.yml`).
3. **Review outputs and manually add the remaining 3 variables**
   * After the first run, manually check output values in logs.
   * Copy dynamic parameters (e.g., S3 alias, external ID) into GitHub environment variables.
4. **Second workflow run (to complete integrations)**
   * Run the same workflow again so Terraform receives the newly added values.
   * This finalizes infrastructure deployment including integration-related resources such as `integration.tf`.

### ✅ First-Time Manual Run Order (DEV/PRD)

For a brand-new environment, the flow is the same for DEV and PRD. Run workflows manually (`workflow_dispatch`) in this order:

1. Terraform AWS workflow (first run)
2. Terraform Snowflake workflow (first run)
3. Add the 3 intermediate variables:
    * `AWS_S3_AP_ALIAS`
    * `SF_USER_ARN`
    * `SF_EXTERNAL_ID`
4. Terraform AWS workflow (second run)
5. Terraform Snowflake workflow (second run)
6. schemachange workflow

Workflow file mapping by environment:

- DEV:
   * `terraform-aws-dev.yml`
   * `terraform-snowflake-dev.yml`
   * `schemachange-dev.yml`
- PRD:
   * `terraform-aws-prd.yml`
   * `terraform-snowflake-prd.yml`
   * `schemachange-prd.yml`

Run schemachange only after Terraform setup is completed.

### 🔁 Post-Bootstrap Workflow Behavior

After first-time bootstrap is complete, workflows run based on changed file scope.

- On `pull_request` / `push`, only workflows whose `paths` conditions match changed files are triggered.
- If changed files do not match a workflow path filter, that workflow does not run automatically.
- `workflow_dispatch` remains available for manual execution (retry, exception handling, or ad-hoc checks).

### 🔄 Why the Same Workflow Runs Multiple Times During a PR

Before a PR is merged into `main`, the same workflow can run multiple times for the same PR.

- `opened`: when the PR is created
- `synchronize`: when additional commits are pushed to the PR branch
- `reopened`: when a closed PR is reopened

In practice, this means relevant workflows are re-run as the PR is updated until merge completion.

### 🔓 Terraform Backend Lock Recovery

If a Terraform workflow is interrupted mid-run, the backend lock may remain.
This can affect both AWS and Snowflake Terraform workflows because both use the same S3 backend locking mechanism.

To avoid manually signing in to AWS and deleting lock artifacts, use:

- `.github/workflows/terraform-unlock.yml`
