# private-fin-data-platform

- English version: [README.md](README.md)

AWS と Snowflake 上で私が運用している、個人向け金融データプラットフォームです。
このリポジトリでは、インフラとデータワークフローを再現可能で明示的、かつコストを意識した形で維持することを重視しています。
透明性のために public として公開しており、設計の一部は似た構成を作る人の参考になるかもしれません。

## 1. プロジェクト概要

このリポジトリは、個人の金融データ活用のための運用基盤です。
意思決定と変更履歴を追いやすくするため、インフラ、マイグレーション、変換処理を1つのモノリポで管理しています。
過度な抽象化よりも、実運用のしやすさを優先しています。

## 2. このリポジトリの位置づけ

これはワンクリックで使えるテンプレートではなく、私自身の運用実装です。
長期的に維持しやすいことを優先して設計しています。
意図的に意見の強い設計判断も含むため、そのまま全ての環境に適合するとは限りません。
このプロジェクトは現在も継続的に作り込んでおり、あえて未完成の領域を残しています。
現時点では、監視/オブザーバビリティの一部、datamart モデル設計の一部判断、長期運用に向けた運用面の強化が作業中です。
最初から全体を固定化するより、責務の境界を明確にしながら段階的に改善する方針を取っています。

## 3. 再利用しやすい要素

個人用途の実装ですが、次のパターンは汎用的に再利用しやすいと考えています。

- Terraform / schemachange / dbt の責務分離
- dev / prd を明示的に分ける環境運用
- 実行境界を明確にした CI/CD 中心の変更フロー
- 小規模継続運用を意識したコスト配慮のデフォルト

## 4. アーキテクチャ概要

このプラットフォームは、次の2層で捉えています。

- Control plane: リポジトリ、CI ワークフロー、Terraform、schemachange、dbt の実行
- Data plane: 取り込みストレージ、Snowflake の DB/スキーマ/テーブル、分析モデル

設計意図とトレードオフは [docs/architecture-and-philosophy.ja.md](docs/architecture-and-philosophy.ja.md) にまとめています。

## 5. リポジトリ構成

- [bootstrap](bootstrap): 初期化用アセット
- [terraform](terraform): 継続的なインフラ・基盤リソース管理
- [schemachange](schemachange): SQL マイグレーションのバージョン管理
- [dbt](dbt): 変換モデルと分析ロジック

## 6. ディレクトリ構成（簡易）

```text
private-fin-data-platform/
|- .github/workflows/      # Workflow 定義は dev/prd で分離
|  |- terraform-aws-dev.yml
|  |- terraform-aws-prd.yml
|  |- terraform-snowflake-dev.yml
|  |- terraform-snowflake-prd.yml
|  |- schemachange-dev.yml
|  `- schemachange-prd.yml
|- bootstrap/              # 初回の手動 bootstrap
|- terraform/              # dev/prd で分離
|  |- aws/dev, aws/prd
|  `- snowflake/dev, snowflake/prd
|- schemachange/           # dev/prd で分離
|  |- datalake/dev, datalake/prd
|  |- datawarehouse/dev, datawarehouse/prd
|  `- datamart/dev, datamart/prd
|- dbt/                    # 共通ディレクトリ（dev/prd 非分離）
|- docs/                   # 設計思想と実行手順
`- sample_data/            # 開発用サンプルデータ
```

環境分離の注意点:

- Terraform・schemachange・GitHub Actions Workflow は dev/prd を分けて管理しています。
- dbt は現在、dev/prd を分けずに共通プロジェクトとして管理しています。

## 7. ドキュメント一覧

- 設計思想: [docs/architecture-and-philosophy.ja.md](docs/architecture-and-philosophy.ja.md)
- 環境構築手順: [docs/operations-runbook.ja.md](docs/operations-runbook.ja.md)
- Bootstrap ガイド: [bootstrap/README.ja.md](bootstrap/README.ja.md)
- schemachange ガイド: [schemachange/README.ja.md](schemachange/README.ja.md)
- dbt ディレクトリ: [dbt](dbt)

## 8. Snowflake スキーマ構成（現時点スナップショット）

現時点で確認しているスキーマレベル構成は次のとおりです。

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

役割メモ（簡潔版）:

- COMMON_DB: 全DBで共通利用するオブジェクトを格納する共通領域。
- COMMON_DB.GOVERNANCE: マスキングポリシーなどのガバナンス系オブジェクトを管理。
- COMMON_DB.UTILS: 汎用的に再利用するUDF/関数を管理。
- DATALAKE_DB: 取り込み直後の生データ層（Medallion Bronze 相当）。
- DATALAKE_DB.COMMON: 取り込み処理向けの共通プロシージャ/ユーティリティを管理。
- DATALAKE_DB.<source_schema>: 各ソーススキーマ（例: PAYPAY_BANK, SBI_SECURITIES）をソースシステム単位で分離。
- DATAWAREHOUSE_DB: 分析しやすい形に整える層（Medallion Silver 相当）。
- DATAWAREHOUSE_DB.STAGING: DATALAKE_DB 由来データの整形層。複数テーブル結合は行わない。
- DATAWAREHOUSE_DB.CORE: 下流分析やAI活用向けの中核データを管理。
- DATAMART_DB: BI/提供先向けのサービング層。
- DATAMART_DB.<consumer_schema>: 提供先単位でスキーマ分離する想定で、外部利用は原則参照専用。

注記: これはスキーマレベルのみの暫定スナップショットであり、今後の実装に応じて更新されます。
