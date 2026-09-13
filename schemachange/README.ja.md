# Schemachange の運用ルール

- English version: [README.md](README.md)

このディレクトリには、DATALAKE、DATAWAREHOUSE、DATAMART 向けの schemachange migration を配置する。

## 現在のレーン状態

- DATALAKE: 稼働中
- DATAMART: 予約レーン（現在は空）
- DATAWAREHOUSE: 予約レーン（現在は空）

現在の境界:
- DATAWAREHOUSE の固定スキーマ（`SCHEMACHANGE`, `STAGING`, `CORE`）は Terraform で管理する。
- DATAMART の `SCHEMACHANGE` スキーマは Terraform で管理する。
- `schemachange/datawarehouse` と `schemachange/datamart` は、将来 schemachange で管理するのが適切な SQL オブジェクト用に残している。

## TASK 運用方針

- 稼働中の datalake パイプラインの TASK 定義は `schemachange/datalake/*/migrations/R/` で管理する。
- 定義変更後の TASK 自動再開は行わない。停止していた workload の意図しない起動を避けるため、再開は明示的な運用操作とする。

## ストリーム・ワークテーブル運用方針（v1.0.9+）

- Directory table ストリーム（`stream_on_stage_*`）は S3 ランディングゾーンのファイル変更を追跡する。
- Stream レコードはすべて work table（transient table）に一度退避してから処理を開始する。これにより、処理中のエラーハンドリングとリトライ時のデータ保持を一元管理できる。
- ストリーム トリガータスク（`WHEN SYSTEM$STREAM_HAS_DATA(...)`）は、新しいファイルが検出されると自動実行される。
- タスク定義には `SUSPEND_TASK_AFTER_NUM_FAILURES = 3` を設定し、エラーループによるコスト爆増を防止する。タスク停止時に work_table に残っているレコードは、次のタスク実行時に再処理される。
- Stream 定義、work_table スキーマ、タスク定義は、すべて versioned migration（V1.0.9+）で管理する。R 系（repeatable）ではデータを持つオブジェクトを管理しない。

## SQL スタイル

migration SQL のカラム定義には、次の整形ルールを適用する。

- カラム名と型名の間は、半角スペースを最低 2 文字入れる。
- 型名と NOT NULL の間は、半角スペースを最低 2 文字入れる。

例:

```sql
payment_date           DATE          NOT NULL,
extra_interest_amount  NUMBER,
created_at             TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP()
```

## 補足

- sqlfluff は一般的な SQL 品質チェックに有効であるが、この見た目の整列ルールは手動レビューが必要になる場合がある。
- すべての migration ファイルで整形ルールを統一すること。
