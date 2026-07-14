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

## 6. Documents Map

- Design philosophy: [docs/architecture-and-philosophy.md](docs/architecture-and-philosophy.md)
- Environment setup guide: [docs/operations-runbook.md](docs/operations-runbook.md)
- Bootstrap guide: [bootstrap/README.md](bootstrap/README.md)
- schemachange guide: [schemachange/README.md](schemachange/README.md)
- dbt directory: [dbt](dbt)
