# private-fin-data-platform

- Japanese: [README.ja.md](README.ja.md)

Personal financial data platform I maintain on AWS and Snowflake.
I use this repository to keep infrastructure and data workflows reproducible, explicit, and cost-aware.
It is public for transparency, and parts of the design may be useful to anyone adapting a similar setup.

## 1. Project Overview

This repository is my operating base for personal finance data use cases.
I keep infrastructure, database migrations, and transformations in one monorepo so decisions and changes stay traceable.
The emphasis is practical operation over perfect abstraction.

## 2. What This Repository Is (and Is Not)

This is a working implementation, not a one-click template.
I optimize it for long-term maintainability in my own environment.
Some choices are intentionally opinionated and may not fit every context as-is.
This project is still evolving, and some areas are intentionally incomplete.
Current work-in-progress areas include parts of monitoring/observability, selected datamart modeling decisions, and operational hardening for long-term maintenance.
I prioritize explicit boundaries and iterative improvements over trying to finalize everything at once.

## 3. Reusable Parts

Even though this is personal, the following patterns are generally reusable:

- Separation across Terraform, schemachange, and dbt
- Explicit dev/prd split for environment management
- CI/CD-centered change flow with clear execution boundaries
- Cost-aware operational defaults for small-scale continuous use

## 4. Architecture at a Glance

I treat the platform as two layers:

- Control plane: repository, CI workflows, Terraform, schemachange, dbt execution
- Data plane: landing storage, Snowflake databases/schemas/tables, analytical models

Design intent and trade-offs are documented in [docs/architecture-and-philosophy.md](docs/architecture-and-philosophy.md).

## 5. Repository Structure

- [bootstrap](bootstrap): one-time initialization assets
- [terraform](terraform): continuous infrastructure and platform resource management
- [schemachange](schemachange): versioned SQL migrations
- [dbt](dbt): transformation models and analytics logic

## 6. Quick Directory Layout

```text
private-fin-data-platform/
|- .github/workflows/      # workflow files are split by dev/prd
|  |- terraform-aws-dev.yml
|  |- terraform-aws-prd.yml
|  |- terraform-snowflake-dev.yml
|  |- terraform-snowflake-prd.yml
|  |- schemachange-dev.yml
|  `- schemachange-prd.yml
|- bootstrap/              # one-time manual bootstrap
|- terraform/              # split by dev/prd
|  |- aws/dev, aws/prd
|  `- snowflake/dev, snowflake/prd
|- schemachange/           # split by dev/prd
|  |- datalake/dev, datalake/prd
|  |- datawarehouse/dev, datawarehouse/prd
|  `- datamart/dev, datamart/prd
|- dbt/                    # shared (not split by dev/prd)
|- docs/                   # architecture and execution guides
`- sample_data/            # local sample files for development
```

Environment boundary note:

- Terraform, schemachange, and GitHub Actions workflows are managed separately for dev and prd.
- dbt is currently managed as a shared project directory, not split into dev/prd.

## 7. Documents Map

- Design philosophy: [docs/architecture-and-philosophy.md](docs/architecture-and-philosophy.md)
- Environment setup guide: [docs/operations-runbook.md](docs/operations-runbook.md)
- Bootstrap guide: [bootstrap/README.md](bootstrap/README.md)
- schemachange guide: [schemachange/README.md](schemachange/README.md)
- dbt directory: [dbt](dbt)

## 8. Snowflake Schema Layout (Current Snapshot)

Current schema-level layout observed in the account:

```text
COMMON_DB
|- GOVERNANCE
`- UTILS

DATALAKE_DB
|- SCHEMACHANGE
|- COMMON
|- MONEX_SECURITIES
|- PAYPAY_BANK
`- SBI_SECURITIES

DATAWAREHOUSE_DB
|- SCHEMACHANGE
|- STAGING
`- CORE

DATAMART_DB
`- SCHEMACHANGE
```

Role notes (concise):

- COMMON_DB: Shared cross-database objects.
- COMMON_DB.GOVERNANCE: Governance assets such as masking policies.
- COMMON_DB.UTILS: Reusable utility UDFs/functions.
- DATALAKE_DB: Raw ingestion layer (Medallion Bronze).
- DATALAKE_DB.COMMON: Shared procedures/utilities for ingestion.
- DATALAKE_DB.<source_schema>: Source schemas (for example, PAYPAY_BANK, SBI_SECURITIES) are split by source system.
- DATAWAREHOUSE_DB: Refined layer for analysis-ready modeling (Medallion Silver).
- DATAWAREHOUSE_DB.STAGING: Table-level reshaping from DATALAKE_DB without multi-table joins.
- DATAWAREHOUSE_DB.CORE: Cross-domain core datasets for downstream analytics and AI use.
- DATAMART_DB: Consumer-facing serving layer for BI/tools.
- DATAMART_DB.<consumer_schema>: Consumer-specific schemas are expected to be separated by destination, with read-only access for external consumers.

Note: This snapshot is intentionally schema-level only and may change as the platform evolves.
