# データプラットフォーム 初期ブートストラップ手順（総合マニュアル）

- English version: [README.md](README.md)

本手順は、CI/CD パイプライン（Terraform / schemachange / dbt）を稼働させる前に、各クラウドプラットフォーム側で一度だけ実行する必要がある手作業の全体フローである。
各プラットフォーム間で設定値（アカウント ID 等）の依存関係があるため、**必ず以下の順序（AWS ➔ Snowflake ➔ GitHub）で実施すること。**

---

## 🚀 セットアップの実行順序・各詳細マニュアル

Bootstrapは必ず以下の順番で実施すること。リンクをクリックすると各プラットフォームの詳細手順（マニュアルTOP）へ移動する。

1. [👉 Step 1: AWSの初期構築](./aws/README.md) — Terraform 用 S3 バックエンド基盤（S3/Access Point/IAM ロール）の作成
2. [👉 Step 2: Snowflakeの初期構築](./snowflake/README.md) — 組織・環境分離（DEV/PRD）とCICD用オブジェクト作成
3. [👉 Step 3: GitHubの環境変数登録](./github/README.md) — 環境（Environments）定義と確定した変数のマッピング

---

## 🏃‍♂️ 各プラットフォーム構築の概要

### 1. AWS の初期セットアップ
* Terraform の状態管理（`tfstate`）を安全に運用するための S3 バックエンド基盤（S3 バケット、Access Point、CI/CD 用 IAM ロール）を、提供された CloudFormation テンプレートから展開する。

### 2. Snowflake の初期セットアップ
* 組織（Organization）アカウントから環境分離された子アカウント（DEV / PRD）を SQL で手動発行する。その後、各子アカウントにログインし、GitHub Actions と OIDC 連携を行うためのセキュリティ統合（Security Integration）やデプロイ用オブジェクト群を整備する。

### 3. GitHub Actions の初期セットアップ
* リポジトリ側に「環境（Environments）」および「変数（Variables）」を定義し、前段のステップで取得した AWS/Snowflake の識別子をマッピングする。また、本番環境への不正デプロイを防ぐための厳格な保護ルール（自己承認の禁止、管理者バイパスの無効化）を構成する。

---

## 🏁 構築完了の確認

すべてのプラットフォームの手作業ステップが完了し、必要な環境変数やブランチ保護が GitHub 側に反映された段階で、`main` ブランチへのコードプッシュ（およびプルリクエストのマージ）による全自動デプロイパイプラインの準備が完了する。

Terraform workflow の失敗で lock ファイルが残った場合は、次の workflow で復旧する。

- [.github/workflows/terraform-unlock.yml](../.github/workflows/terraform-unlock.yml)
