# 環境構築手順

- English version: [operations-runbook.md](operations-runbook.md)

このドキュメントは、初回の環境構築手順のみをまとめたものです。
設計思想の説明とは分離して管理します。

## 1. 対象範囲

本ドキュメントでは、初回の環境構築手順のみを扱います。

設計意図やトレードオフは [architecture-and-philosophy.ja.md](architecture-and-philosophy.ja.md) を参照してください。

## 2. 初回セットアップ手順（環境ごと）

新規環境は次の順序で実施します。

1. 手動Bootstrapを次の順で完了する。
   - [bootstrap/aws/README.md](../bootstrap/aws/README.md)
   - [bootstrap/snowflake/README.md](../bootstrap/snowflake/README.md)
   - [bootstrap/github/README.md](../bootstrap/github/README.md)
2. 対象のGitHub Environmentに初期変数を登録する。
   - `AWS_ACCOUNT_ID`
   - `PROJECT_PREFIX`
   - `SF_ORGANIZATION_NAME`
   - `SF_ACCOUNT_NAME`
3. Terraformワークフローを1回実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`
4. Outputsを確認し、中間変数を登録する。
   - `AWS_S3_AP_ALIAS`
   - `SF_USER_ARN`
   - `SF_EXTERNAL_ID`
5. Terraformワークフローを再実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`
6. schemachangeワークフローを実行する。
   - `schemachange-<env>.yml`

補足:

- `<env>` は `dev` または `prd`。
- schemachange は Terraform 側の連携リソース作成後に実行する。

## 3. 関連ドキュメント

- [README.ja.md](../README.ja.md)
- [bootstrap/README.ja.md](../bootstrap/README.ja.md)
- [schemachange/README.ja.md](../schemachange/README.ja.md)
- [dbt](../dbt)