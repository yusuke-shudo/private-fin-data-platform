# private-fin-data-platform: Architecture and Design Philosophy

- 日本語版: [architecture-and-philosophy.ja.md](architecture-and-philosophy.ja.md)

## 1. What This System Is

This repository is a reference implementation of a personal financial data platform built with AWS, Snowflake, and GitHub Actions.

The goal is not to provide a one-click production template. The goal is to make core design decisions explicit and reusable:

- How to separate infrastructure, schema change, and transformation responsibilities
- How to keep deployment repeatable and observable
- How to design for low-cost personal operation without losing production-level discipline

When there is no strong external constraint, this repository uses the design and implementation choices I believe are the most practical. In that sense, it should be read as a working example rather than a generic template.

Concrete examples of that approach include:

- Both AWS and Snowflake use organization-level account separation, with dedicated accounts for `dev` and `prd`.
	In Snowflake especially, many companies still run dev/prd inside a single account, so this repository intentionally adopts a stricter split model.
- Terraform uses Snowflake provider preview features such as `snowflake_stage_resource` and `snowflake_storage_integration_aws_resource`.
- AWS and Snowflake setup live in a single monorepo, so approval responsibilities may belong to either AWS administrators or Snowflake administrators depending on the change area.
- The default CI/CD flow is `main`-branch PR-driven DEV automation; branch styles such as `dev` or `next` are not part of the intended normal flow.
- Snowflake ingestion is intentionally centralized into `DATALAKE_DB`.
- Raw datalake tables are intentionally simple and usually follow a 4-column layout (`ingest_at`, `file_path`, `line_number`, `raw_payload`) for ELT-oriented ingestion.

## 2. Design Principles

### 2.1 Separation of Responsibilities

- Terraform manages infrastructure and platform-level resources.
- schemachange manages SQL migrations for database objects that should be versioned as DDL.
- dbt manages transformation logic and analytical modeling.

Each layer has a single primary role, which reduces hidden coupling and review complexity.

### 2.2 Repeatability Over Convenience

The same operation should produce the same outcome regardless of who executes it.

- Environment-specific values are injected via environment variables.
- CI workflows are deterministic and versioned with the code.
- Migration history is persisted and auditable.

### 2.3 Safe-by-Default Delivery

This system favors explicit checks before irreversible changes.

- Pull requests are used to validate migration and infrastructure changes.
- Production workflows distinguish verification from deployment.
- Deployment steps are ordered so dependencies are resolved predictably.

### 2.4 Cost-Aware Operation

For personal usage, cost control is treated as a design constraint.

- Small default compute profile
- Short-lived execution patterns
- Operational preference for manual or low-frequency execution where practical

## 3. Architecture Overview

At a high level, the architecture is split into control plane and data plane.

- Control plane: GitHub repository, CI workflows, Terraform, schemachange, dbt execution
- Data plane: S3 landing, Snowflake databases/schemas/tables, transformed analytical models

This separation keeps deployment mechanics independent from business data modeling.

## 4. Data Lifecycle

The system follows a layered lifecycle:

1. Ingest raw files into datalake raw tables
2. Normalize and model data into datawarehouse
3. Publish analytics-oriented structures in datamart

Raw ingestion is not append-only by default. Depending on data characteristics, it can be append, full refresh, or slice-based reload (DELETE+INSERT or MERGE).
For yearly files such as transfer profit/loss reports, `year` is used as the slice key to rebuild only the affected slice.

## 5. Why Terraform + schemachange + dbt

These tools are intentionally combined, not duplicated.

- Terraform: account/database/schema-level infrastructure and integration primitives
- schemachange: versioned SQL migrations for database DDL evolution
- dbt: model lineage, testing, and transformation orchestration

The boundary is practical: platform objects and migration mechanics stay out of dbt models, while analytics logic stays out of infrastructure code.

## 6. Reliability and Operability

Operational reliability is improved through simple, explicit patterns:

- Ordered execution for dependent steps
- Environment separation (dev/prd)
- Versioned CI workflow definitions
- Change history tables for migration traceability

The current workflow strategy prioritizes fewer approval interruptions and lower operational friction while preserving ordering guarantees.

## 7. Security and Governance Posture

This repository is public and intended for design transparency.

- It contains sample data only
- Secrets are not stored in the repository
- Runtime credentials are expected to be provided by workload identity and environment configuration

The implementation demonstrates a pattern, not organizational trust policy.

## 8. Trade-offs and Non-Goals

### Trade-offs

- Simpler workflows can reduce operational overhead but provide less per-step isolation.
- Personal cost optimization may prefer manual execution over full automation.
- Public readability can limit inclusion of organization-specific controls.

### Non-Goals

- This repository does not attempt to encode every enterprise governance requirement.
- It does not prescribe one universal operating model for all organizations.

## 9. Future Direction

Likely evolution paths:

- More granular workflow segmentation by domain or database when needed
- Expanded policy management (e.g., masking and row access) where dbt is not the right control surface
- Stronger cost guardrails for serverless usage visibility

The guiding rule remains the same: introduce complexity only when it buys clear operational value.
