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

## 6. ドキュメント一覧

- 設計思想: [docs/architecture-and-philosophy.ja.md](docs/architecture-and-philosophy.ja.md)
- 環境構築手順: [docs/operations-runbook.ja.md](docs/operations-runbook.ja.md)
- Bootstrap ガイド: [bootstrap/README.ja.md](bootstrap/README.ja.md)
- schemachange ガイド: [schemachange/README.ja.md](schemachange/README.ja.md)
- dbt ディレクトリ: [dbt](dbt)
