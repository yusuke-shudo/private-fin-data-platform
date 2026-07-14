# 環境構築手順

- English version: [operations-runbook.md](operations-runbook.md)

このドキュメントは、初回の環境構築手順のみをまとめたものです。
設計思想の説明とは分離して管理します。

## 1. 対象範囲

本ドキュメントでは、初回の環境構築手順のみを扱います。

設計意図やトレードオフは [architecture-and-philosophy.ja.md](architecture-and-philosophy.ja.md) を参照してください。

## 2. 責務境界（実行観点）

- Bootstrap は、各プラットフォームの初回手動前提を初期化する。
- Terraform ワークフローは、固定的な基盤境界（DB/スキーマ/ベース権限）を継続管理する。
- schemachange は、Terraform による基盤整備後に必要な SQL マイグレーションをバージョン管理する。
- dbt は、許可されたスキーマ内の変換モデルを管理する。

## 3. 初回セットアップ手順（環境ごと）

プラットフォーム別手順に入る前に、Bootstrapの入口として [bootstrap/README.ja.md](../bootstrap/README.ja.md) を先に参照してください。

### 3.1 手動Bootstrap + 初期変数登録

1. 手動Bootstrapを次の順で完了する。
   - [bootstrap/aws/README.md](../bootstrap/aws/README.md)
   - [bootstrap/snowflake/README.md](../bootstrap/snowflake/README.md)
   - [bootstrap/github/README.md](../bootstrap/github/README.md)
2. 対象のGitHub Environmentに初期変数を登録する。
   - `AWS_ACCOUNT_ID`
   - `PROJECT_PREFIX`
   - `SF_ORGANIZATION_NAME`
   - `SF_ACCOUNT_NAME`

### 3.2 Terraform 1回目

1. Terraformワークフローを1回実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.3 中間変数登録

1. Outputsを確認し、中間変数を登録する。
   - `AWS_S3_AP_ALIAS`
   - `SF_USER_ARN`
   - `SF_EXTERNAL_ID`

### 3.4 Terraform 2回目

1. Terraformワークフローを再実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.5 schemachange 実行

1. schemachangeワークフローを実行する。
   - `schemachange-<env>.yml`

補足:

- `<env>` は `dev` または `prd`。
- schemachange は Terraform 側の連携リソース作成後に実行する。
- Terraform workflow の失敗で lock ファイルが残った場合は、[terraform-unlock.yml](../.github/workflows/terraform-unlock.yml) で復旧する。

参照ディレクトリ（本手順で見る場所）:

- Workflow 定義: [.github/workflows/](../.github/workflows/)
- Terraform AWS: [terraform/aws/dev/](../terraform/aws/dev/) および [terraform/aws/prd/](../terraform/aws/prd/)
- Terraform Snowflake: [terraform/snowflake/dev/](../terraform/snowflake/dev/) および [terraform/snowflake/prd/](../terraform/snowflake/prd/)
- schemachange レーン: [schemachange/datalake/dev/](../schemachange/datalake/dev/) および [schemachange/datalake/prd/](../schemachange/datalake/prd/)

## 4. 構築完了の判定

対象環境について、次の条件をすべて満たした時点を初回構築完了とする。

- 手動Bootstrap（AWS -> Snowflake -> GitHub）が完了している。
- GitHub Environment の初期変数（`AWS_ACCOUNT_ID`, `PROJECT_PREFIX`, `SF_ORGANIZATION_NAME`, `SF_ACCOUNT_NAME`）が登録済みである。
- Terraform AWS と Terraform Snowflake のワークフローが、2回目の実行まで成功している。
- 中間変数（`AWS_S3_AP_ALIAS`, `SF_USER_ARN`, `SF_EXTERNAL_ID`）が登録済みである。
- Terraform 側の連携リソース作成完了後に、schemachange ワークフローが完了している。

## 5. 関連ドキュメント

- [README.ja.md](../README.ja.md)
- [bootstrap/README.ja.md](../bootstrap/README.ja.md)
- [schemachange/README.ja.md](../schemachange/README.ja.md)
- [dbt](../dbt)