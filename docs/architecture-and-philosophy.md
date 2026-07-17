# private-fin-data-platform: Architecture and Design Philosophy

- Japanese version: [architecture-and-philosophy.ja.md](architecture-and-philosophy.ja.md)

## 1. Positioning

This repository is a personal but production-minded implementation of a financial data platform on AWS and Snowflake.

It is intentionally not a one-click template.
Its primary purpose is to make design boundaries explicit, keep operations reproducible, and show realistic trade-offs under practical constraints.

## 2. Core Principles

### 2.1 Clear Responsibility Boundaries

- Terraform manages platform and infrastructure resources.
- schemachange manages versioned SQL migration assets.
- dbt manages transformation and analytics modeling.

Each layer has one primary responsibility to reduce coupling and review ambiguity.

### 2.2 Reproducibility Over Convenience

- The same change should be executable by anyone with the same result.
- Environment differences are controlled explicitly by environment-specific configuration.
- CI workflow definitions are versioned in the repository.

### 2.3 Explicitness Over Hidden Automation

- One-time bootstrap work is documented as manual initialization.
- Continuous operations are separated from bootstrap.
- Execution order is documented and kept deterministic.

### 2.4 Cost-Aware Design

- Small-scale personal operation is a first-class constraint.
- Storage-first patterns are preferred over unnecessary compute-heavy preprocessing.

## 3. Environment Strategy

### 3.1 Current and Expected Environments

- The current baseline is two environments: dev and prd.
- Additional environments (for example, stg) are expected to be possible.

Terraform and schemachange already use environment-split directory structures, so adding environments is an extension of the existing pattern.

### 3.2 Branching Implications

- For infrastructure and migration assets, GitHub Flow around main is the default operational model.
- As environments increase, dbt may require additional branch discipline beyond simple main-only flow.
- A Git Flow-like stage for dbt can be introduced when validation complexity requires it.

## 4. Repository and Approval Boundaries

AWS and Snowflake are currently managed in a single repository.

- The default approval boundary is expressed by CODEOWNERS.
- In some organizations, approval responsibilities can be split by organizational or political constraints.
- If CODEOWNERS-based separation is insufficient, splitting repositories is a valid option.

The key goal is not monorepo purity but clear accountability for review and release decisions.

## 5. AWS Architecture Policy

### 5.1 Preferred Model (Multi-Account)

1. Create dev OU and prd OU manually.
2. Apply the same template to both OUs.
3. The template prepares Terraform execution baseline resources:
	- S3 for tfstate
	- S3 Access Point for GitHub Actions access
	- IAM role for access path control

The IAM role itself should stay minimal, and access control should be enforced at the Access Point policy layer.

### 5.2 Access Model

- Human login users are managed from the organization account via SSO.

### 5.3 Fallback When Organization Account Is Not Available

- Create a dedicated account for user management and StackSets management.
- Use switch-role into each target account.
- Use StackSets for baseline environment provisioning.

### 5.4 Single-Account Constraint (Not Preferred)

When only one AWS account is available:

- Separate resources by environment naming conventions.
- Separate roles for dev and prd operations.
- Apply strict cost allocation discipline (for example, tags).

This model is operationally possible but increases risk and governance burden.

## 6. Snowflake Architecture Policy

### 6.1 Datalake Strategy

The platform philosophy is to gather all data into Snowflake first.

- Snowflake is treated as the primary datalake platform.
- As long as cost permits, source data should be accepted and stored as raw as possible.
- Data providers should not be forced to build custom ETL just for delivery.

### 6.2 Schema and Database Layering

- DATALAKE_DB: raw ingestion layer (Bronze)
- DATAWAREHOUSE_DB: standardized and refined layer (Silver)
- DATAMART_DB: consumer-facing serving layer

Within DATALAKE_DB, schemas are split by source system.

### 6.3 Standardization Policy

- Standardization starts in STAGING.
- Column-name drift, semantic drift, and structural inconsistencies should be normalized as early as practical.
- STAGING should avoid multi-table joins and focus on shape harmonization.

### 6.4 Core Data and Distribution

- CORE should be designed for downstream analytics and AI use.
- CORE should also be publishable in Iceberg format where practical.
- This enables consumers to use S3 access paths without requiring direct Snowflake usage.

### 6.5 Account Strategy

Preferred model:

- Create separate Snowflake accounts for dev and prd manually.
- In each account, separate roles, users, and warehouses by purpose (platform operation vs data application).

Fallback model (single account only):

- Separate databases, roles, warehouses, and service users by environment naming conventions.

### 6.6 Developer Schema Boundary (Current Policy)

- Canonical schemas in `DATAWAREHOUSE_DB` (especially `STAGING` and `CORE`) are expected to be updated through CI/CD execution paths.
- Human developer trial-and-error should occur in personal custom schemas, not in canonical shared schemas.
- This keeps reviewability and reproducibility aligned with pull-request-based change flow.
- The policy may evolve, but CI/CD-first schema protection is the current default stance.

## 7. Operational Model

### 7.1 Bootstrap vs Continuous Operations

- Bootstrap is one-time manual initialization.
- Terraform and schemachange handle continuous managed changes afterward.

### 7.2 Task Ownership and Execution Posture

- Task definitions are managed as migration assets.
- Automatic resume behavior after task redefinition is intentionally avoided.
- Execution and privilege boundaries are kept explicit and close to the managed objects.

### 7.3 Developer Workbench and Identity Boundary

- Developer workbench instances are treated as disposable execution surfaces, not identity stores.
- Provisioning/deletion should stay in Terraform workflow control to avoid state drift.
- Ownership and access boundaries should be enforced with tags (especially `Owner`) and IAM conditions.
- Human developer lifecycle management remains outside Git; repository-managed policy defines technical boundaries only.
- Support access is allowed as an explicit exception path with approval and audit logging.

## 8. Security and Transparency Posture

- This is a public repository for design transparency.
- No secrets should be stored in source control.
- Runtime authentication should rely on workload identity and environment configuration.
- Sample data and demonstrative patterns are included, not enterprise-wide trust policy.

## 9. Trade-offs

- A single repository improves cross-layer traceability but can complicate reviewer boundaries.
- Main-centered flow is efficient for infrastructure and migration layers but may become insufficient for dbt at higher environment complexity.
- Single-account fallback patterns are pragmatic but carry higher operational risk.

## 10. Non-Goals

- This repository does not claim to be a universal enterprise standard.
- It does not attempt to encode every governance requirement for every organization.
- It is not optimized for organizations that require strict domain-by-domain platform separation from day one.

## 11. Evolution Direction

Likely next steps:

- Add explicit stg expansion rules for Terraform/schemachange/workflows.
- Define objective criteria for when dbt branch strategy should evolve beyond main-only flow.
- Expand governance assets (for example masking and policy controls) as usage grows.
- Harden Iceberg-based delivery contracts for non-Snowflake consumers.

The guiding principle remains unchanged: add complexity only when it provides clear operational value.
