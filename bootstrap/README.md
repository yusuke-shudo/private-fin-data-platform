# データプラットフォーム 初期ブートストラップ手順（総合マニュアル）

本手順は、CI/CD パイプライン（Terraform / schemachange / dbt）を稼働させる前に、各クラウドプラットフォーム側で一度だけ実行する必要がある手作業の全体フローである。
各プラットフォーム間で設定値（アカウント ID 等）の依存関係があるため、**必ず以下の順序（AWS ➔ Snowflake ➔ GitHub）で実施すること。**

## 🏃‍♂️ プラットフォーム構築シーケンス

1. **AWS の初期セットアップ**
* **概要**: Terraform の状態管理（`tfstate`）を安全に保存するための S3 バケット、および排他制御用の DynamoDB テーブル（State Lock 用）等を、提供された CloudFormation テンプレートから手動で作成する。
* **詳細マニュアル**: [aws/README.md](https://www.google.com/search?q=./aws/README.md) を参照して実行。

2. **Snowflake の初期セットアップ**
* **概要**: 組織（Organization）アカウントから環境分離された子アカウント（DEV / PRD）を SQL で手動発行する。その後、各子アカウントにログインし、GitHub Actions と OIDC 連携を行うためのセキュリティ統合（Security Integration）やデプロイ用オブジェクト群を整備する。
* **詳細マニュアル**: [snowflake/README.md](https://www.google.com/search?q=./snowflake/README.md) を参照して実行。

3. **GitHub Actions の初期セットアップ**
* **概要**: リポジトリ側に「環境（Environments）」および「変数（Variables）」を定義し、前段のステップで取得した AWS/Snowflake の識別子をマッピングする。また、本番環境への不正デプロイを防ぐための厳格な保護ルール（自己承認の禁止、管理者バイパスの無効化）を構成する。
* **詳細マニュアル**: [github/README.md](https://www.google.com/search?q=./github/README.md) を参照して実行。


---

## 🏁 構築完了の確認

すべてのプラットフォームの手作業ステップが完了し、必要な環境変数やブランチ保護が GitHub 側に反映された段階で、`main` ブランチへのコードプッシュ（およびプルリクエストのマージ）による全自動デプロイパイプラインの準備が完了する。
