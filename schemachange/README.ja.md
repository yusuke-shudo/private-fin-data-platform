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
