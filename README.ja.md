# private-fin-data-platform

- English version: [README.md](README.md)

AWSおよびSnowflakeを組み合わせたデータプラットフォームのインフラ・オブジェクト群を、Terraformを用いて一元管理するモノリポ（Monorepo）リポジトリである。

---

## 📘 0. 設計思想ドキュメント

システムの思想・設計方針を先に把握したい場合は、以下を参照する。

- [Architecture and Design Philosophy](docs/architecture-and-philosophy.md)
- [設計思想とアーキテクチャ（日本語版）](docs/architecture-and-philosophy.ja.md)

---

## 🗺️ 1. ディレクトリ構造

本リポジトリは、環境の初期構築を行う「bootstrap」、schemachange 用の「schemachange」、継続的なインフラ管理を行う「terraform」の3つのディレクトリで構成されている。

```text
├── .github/workflows/       # CI/CD ワークフロー定義（環境・プロバイダー別）
│   ├── tf-aws-dev.yml
│   ├── tf-aws-prd.yml
│   ├── tf-snowflake-dev.yml
│   ├── tf-snowflake-prd.yml
│   └── tf-unlock.yml        # 状態ロック解除用
├── CODEOWNERS               # コード変更の承認責任者定義
├── bootstrap/               # 1. 初期構築フェーズ（各環境変数等の作成手順）
│   ├── aws/                 # S3バックエンド、CloudFormationテンプレート等
│   ├── github/              # 環境変数の初期登録・管理ルール
│   └── snowflake/           # 組織管理者・CICD用ユーザー初期セットアップSQL
├── schemachange/           # schemachange 管理（検証用、dev/prd、マイグレーション）
└── terraform/               # 2. 継続管理フェーズ（自動デプロイ対象）
    ├── aws/                 # AWSリソース管理（ネットワーク、IAM、S3等）
    │   ├── dev/
    │   └── prd/
    └── snowflake/           # Snowflakeリソース管理（統合、DB、ロール等）
        ├── dev/
        └── prd/
```

---

## ⚙️ 2. コンポーネントと管理環境

プロバイダー（対象クラウド）と環境（dev / prd）ごとにワークフローおよびTerraform実行ディレクトリが完全に分離されている。

| ディレクトリ | 対象プラットフォーム | 管理環境 | 主要ファイル構成 |
| :--- | :--- | :--- | :--- |
| **`terraform/aws/`** | Amazon Web Services | `dev` / `prd` | main, providers, backend, variables, outputs.tf |
| **`terraform/snowflake/`** | Snowflake | `dev` / `prd` | main, providers, backend, variables, outputs, integration.tf |

> 💡 **環境間の対称性について**
> 現在、`dev` 和 `prd` のディレクトリ構造および構成ファイル（`variables.tf` 等）は完全に一致した対称性を保っている。環境固有のパラメータ差分は、GitHub Environmentsの変数機能等を通じて制御される。

---

## 🔐 3. GitHub Environments（環境）の設定

GitHubの **Settings > Environments** で定義された以下の環境を利用して、デプロイ対象や権限を制御している。

* **`dev-infra` / `prd-infra`**: 主に `terraform/aws/` 側のインフラ土台用環境
* **`dev-data` / `prd-data`**: 主に `terraform/snowflake/` 側および、将来的な **schemachange / dbt** によるデータオブジェクト・ELT構築用環境

---

## 🚀 4. 初期構築（Bootstrap）からTerraform完了までの実行フロー

環境を新しく立ち上げる際は、依存関係（鶏と卵）を解消するために、以下の順序に沿って初期構築とワークフローの **2段階実行** を行う。

### 🔄 管理する合計7つの環境変数
* **Bootstrap手順内で登録する変数 (4つ)**: `AWS_ACCOUNT_ID`, `PROJECT_PREFIX`, `SF_ORGANIZATION_NAME`, `SF_ACCOUNT_NAME`
* **中間手動追記する変数 (3つ)**: `AWS_S3_AP_ALIAS`, `SF_USER_ARN`, `SF_EXTERNAL_ID`

### 📋 セットアップ手順

1. **Bootstrapの実施 ＆ 初期4変数の登録**
   * `bootstrap/` 配下の手順（CloudFormationの適用、Snowflakeでの初期SQL実行など）を順に実施する。
   * **この手順の中で確定した「初期4変数」** を、GitHubの対象環境（例: `dev-infra`）の画面から登録する。
2. **【1回目】ワークフロー実行（動的値の確定）**
   * 対象のインフラワークフロー（例: `tf-aws-dev.yml`）を1回実行する。
3. **Outputsの目視確認 ＆ 3変数の手動追記**
   * 1回目のワークフロー完了後、**ログに出力された Outputs を目視確認**する。
   * 表示された動的なパラメータ（S3別名や外部IDなど）を、人間が手動で残りの「中間手動追記（3つ）」としてGitHubの環境変数画面にコピペする。
4. **【2回目】ワークフロー実行（接続・インテグレーションの完了）**
   * 追記した変数をTerraformに正しくインプットさせるため、**もう1回同じワークフローを実行**する。これにより、環境変数として注入された動的パラメータを用いて、裏側の連携処理（`integration.tf` 等）を含むすべてのインフラデプロイが正常に完了する。

### ✅ 初回の手動実行順（DEV/PRD 共通）

新規環境では、DEV と PRD で手順は同じである。次の順で `workflow_dispatch` により手動実行する。

1. Terraform AWS ワークフロー（1回目）
2. Terraform Snowflake ワークフロー（1回目）
3. 中間3変数を設定する。
    * `AWS_S3_AP_ALIAS`
    * `SF_USER_ARN`
    * `SF_EXTERNAL_ID`
4. Terraform AWS ワークフロー（2回目）
5. Terraform Snowflake ワークフロー（2回目）
6. schemachange ワークフロー

環境ごとの対象ワークフロー:

- DEV:
   * `terraform-aws-dev.yml`
   * `terraform-snowflake-dev.yml`
   * `schemachange-dev.yml`
- PRD:
   * `terraform-aws-prd.yml`
   * `terraform-snowflake-prd.yml`
   * `schemachange-prd.yml`

schemachange は Terraform 側のセットアップ完了後に実行すること。

### 🔁 初回セットアップ後のワークフロー挙動

初回セットアップ完了後は、変更ファイルの範囲に応じてワークフローが起動する。

- `pull_request` / `push` では、変更ファイルが `paths` 条件に一致したワークフローのみ自動起動する。
- 変更ファイルが対象パスに一致しないワークフローは自動起動しない。
- 例外対応（再実行、障害時対応、臨時確認）では `workflow_dispatch` により手動実行できる。

### 🔄 プルリク中に同じワークフローが複数回動く理由

PR が `main` にマージされる前は、同じワークフローが複数回実行されることがある。

- `opened`: PR 作成時
- `synchronize`: PR ブランチに追加コミットを push した時
- `reopened`: 一度閉じた PR を再オープンした時

実運用上は、PR の更新に応じて関連ワークフローが再実行され、マージ完了まで検証が繰り返される。
