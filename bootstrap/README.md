# 初期ブートストラップ（手作業手順書）

CI/CDパイプライン（Terraform/schemachange/dbt）を稼働させる前に、各クラウドプラットフォーム側で1度だけ実行する必要がある手作業のまとめです。必ず以下の順番で実施してください。

## 🏃‍♂️ セットアップ手順

- [ ] **Step 1: AWSの初期設定**
  Terraformのバックエンド（tfstate保存用）となるS3バケット等を作成します。
  👉 詳細は [aws/README.md](./aws/README.md) を参照。

- [ ] **Step 2: Snowflakeの初期設定**
  組織アカウントおよび子アカウントを作成し、OIDC連携ユーザーとWHを準備します。
  👉 詳細は [snowflake/README.md](./snowflake/README.md) を参照。

- [ ] **Step 3: GitHub Actionsの初期設定**
  GitHubリポジトリに `dev` / `prd` の Environment を作成し、SnowflakeのアカウントIDなどを変数として登録します。
  👉 詳細は [github/README.md](./github/README.md) を参照。

すべてにチェックがついたら、`main` ブランチへのコードマージによる自動デプロイの準備は完了です！
