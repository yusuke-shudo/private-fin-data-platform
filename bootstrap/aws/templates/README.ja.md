# AWS ブートストラップテンプレート

- English version: [README.md](README.md)

このディレクトリには、AWS ブートストラップ時に StackSets から利用する CloudFormation テンプレートを配置しています。

## テンプレート一覧

### fin-data-tfstate-base.yaml

目的:
- 各ターゲットアカウント（`dev` / `prd`）で、Terraform バックエンドと CI/CD アクセスに必要な基盤リソースを作成する。

主な作成リソース:
- GitHub Actions 用 IAM OIDC Provider
- Terraform state アクセス用 IAM ロール: `github-actions-tfstate-access-role`
- リソース作成用 IAM ロール: `github-actions-resource-creation-role`
- Terraform state 用 S3 バケット: `<ProjectPrefix>-<env>-tfstate`
- 制御アクセス用 S3 Access Point
- 制限付きアクセスと TLS 1.2+ を強制する S3 バケットポリシー / Access Point ポリシー

主要パラメータ:
- `Environment`: `dev` または `prd`
- `GitHubOwner`: GitHub 組織名またはユーザー名
- `GitHubRepository`: GitHub リポジトリ名
- `ProjectPrefix`: S3 名称のグローバル重複を避けるためのプレフィックス

主要Outputs:
- `GitHubActionsRoleArn`
- `GitHubActionsResourceCreationRoleArn`
- `S3BucketName`
- `S3AccessPointArn`

## 環境差分

- リソース名は `Environment` と `ProjectPrefix` によって環境ごとに分離されます。
- セキュリティ制御は dev/prd 間で意図的に共通化しています。

## 変更時の注意

- IAM ロール名と Output 名は、CI/CD と Terraform から参照される契約面として扱ってください。
- 信頼ポリシーやバケットポリシーの変更は、`prd` 適用前に慎重に確認してください。
