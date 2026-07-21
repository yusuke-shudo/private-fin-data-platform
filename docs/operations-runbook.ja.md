# 環境構築手順

- English version: [operations-runbook.md](operations-runbook.md)

このドキュメントは、初回の環境構築手順のみをまとめたものです。
設計思想の説明とは分離して管理します。

## 1. 対象範囲

本ドキュメントでは、初回の環境構築手順のみを扱います。

設計意図やトレードオフは [architecture-and-philosophy.ja.md](architecture-and-philosophy.ja.md) を参照してください。

## 2. 責務境界（実行観点）

- Bootstrap は、各プラットフォームの初回手動前提を初期化する。
- Terraform ワークフローは、固定的な基盤境界（DB/スキーマ/ベース権限）を継続管理する。
- schemachange は、Terraform による基盤整備後に必要な SQL マイグレーションをバージョン管理する。
- dbt は、許可されたスキーマ内の変換モデルを管理する。

## 3. 初回セットアップ手順（環境ごと）

プラットフォーム別手順に入る前に、Bootstrapの入口として [bootstrap/README.ja.md](../bootstrap/README.ja.md) を先に参照してください。

### 3.1 手動Bootstrap + 初期変数登録

1. 手動Bootstrapを次の順で完了する。
   - [bootstrap/aws/README.md](../bootstrap/aws/README.md)
   - [bootstrap/snowflake/README.md](../bootstrap/snowflake/README.md)
   - [bootstrap/github/README.md](../bootstrap/github/README.md)
2. 対象のGitHub Environmentに初期変数を登録する。
   - `AWS_ACCOUNT_ID`
   - `PROJECT_PREFIX`
   - `SF_ORGANIZATION_NAME`
   - `SF_ACCOUNT_NAME`

### 3.2 Terraform 1回目

1. Terraformワークフローを1回実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.3 中間変数登録

1. Outputsを確認し、中間変数を登録する。
   - `AWS_S3_AP_ALIAS`
   - `SF_USER_ARN`
   - `SF_EXTERNAL_ID`

### 3.4 Terraform 2回目

1. Terraformワークフローを再実行する。
   - `terraform-aws-<env>.yml`
   - `terraform-snowflake-<env>.yml`

### 3.5 schemachange 実行

1. schemachangeワークフローを実行する。
   - `schemachange-<env>.yml`

補足:

- `<env>` は `dev` または `prd`。
- schemachange は Terraform 側の連携リソース作成後に実行する。
- Terraform workflow の失敗で lock ファイルが残った場合は、[terraform-unlock.yml](../.github/workflows/terraform-unlock.yml) で復旧する。

参照ディレクトリ（本手順で見る場所）:

- Workflow 定義: [.github/workflows/](../.github/workflows/)
- Terraform AWS: [terraform/aws/dev/](../terraform/aws/dev/) および [terraform/aws/prd/](../terraform/aws/prd/)
- Terraform Snowflake: [terraform/snowflake/dev/](../terraform/snowflake/dev/) および [terraform/snowflake/prd/](../terraform/snowflake/prd/)
- schemachange レーン: [schemachange/datalake/dev/](../schemachange/datalake/dev/) および [schemachange/datalake/prd/](../schemachange/datalake/prd/)

## 4. 構築完了の判定

対象環境について、次の条件をすべて満たした時点を初回構築完了とする。

- 手動Bootstrap（AWS -> Snowflake -> GitHub）が完了している。
- GitHub Environment の初期変数（`AWS_ACCOUNT_ID`, `PROJECT_PREFIX`, `SF_ORGANIZATION_NAME`, `SF_ACCOUNT_NAME`）が登録済みである。
- Terraform AWS と Terraform Snowflake のワークフローが、2回目の実行まで成功している。
- 中間変数（`AWS_S3_AP_ALIAS`, `SF_USER_ARN`, `SF_EXTERNAL_ID`）が登録済みである。
- Terraform 側の連携リソース作成完了後に、schemachange ワークフローが完了している。

## 5. 開発用 Workbench 運用ルール（EC2 + dbt）

この節では、dbt のローカル開発に使う開発用 Workbench EC2 の最小運用ルールを定義します。

### 5.1 作成・削除の境界

- Workbench network の管理は `workbench-network-aws.yml` 経由のみにする。
- owner 単位の Workbench IAM identity の管理は `workbench-identity-aws.yml` 経由のみにする。
- 開発者用 Workbench EC2 の作成と削除は `workbench-instance-aws.yml` 経由のみにする。
- この用途では開発者が Terraform を直接実行しない。
- Terraform state ドリフト防止のため、EC2 コンソールからの手動 terminate は避ける。

### 5.2 Workbench network mode

- Workbench network は現時点では dev 専用とする。
- public/private subnet と Snowflake 側で許可する EIP は `az1` / `az2` の両方に保持する。
- NAT instance は `nat_mode` で制御する。
   - `none`: VPC/subnet/EIP は保持し、NAT instance は起動しない。
   - `az1_only`: `az1` の NAT instance のみ起動する。
   - `az2_only`: `az2` の NAT instance のみ起動する。
   - `az1_az2`: 両方の AZ slot で NAT instance を起動する。
- `none` は低コストの休止モードであり、環境全体の削除ではない。
- EIP 解放を含む完全削除は例外的な環境廃棄として扱い、通常 workflow には含めない。

### 5.3 Workbench instance の境界

- Workbench IAM identity は AZ slot ではなく GitHub actor 単位で定義する。
- 同じ owner 単位の IAM role / instance profile を、その開発者の `az1` / `az2` Workbench EC2 で共有する。
- Instance の所有境界は GitHub actor と AZ slot の組み合わせで定義する。
- 開発者は AZ slot ごとに 1 台の Workbench EC2 を管理できる。
- Identity の Terraform state は `owner` ごとに分離する。
- Instance の Terraform state は `owner` と `az_slot` ごとに分離し、ある開発者の操作が別の開発者の instance を plan / 変更しないようにする。
- `Owner` タグは自由入力ではなく workflow 実行者から設定する。

推奨するセットアップ順序:

1. `workbench-network-aws.yml` で共有 network と AZ ごとの EIP を作成する。
2. `workbench-identity-aws.yml` で owner 単位の IAM role / instance profile を作成する。
3. owner 単位の IAM role ARN を `WORKLOAD_IDENTITY` として使い、Snowflake 側の Workbench service user を作成または更新する。
4. 対象の `az_slot` に対して `workbench-instance-aws.yml` を実行する。

Session Manager で接続した後、開発用ユーザに切り替え、private repository は対話的に clone する。

```bash
sudo -iu ec2-user
gh auth login
gh repo clone yusuke-shudo/private-fin-data-platform ~/private-fin-data-platform
```

Workbench EC2 には Git、GitHub CLI、Python 3.14、dbt、dbt-snowflake、sqlfluff を初期導入する。Amazon Linux が管理する `python3` は変更せず、`ec2-user` の対話 shell では `python` と `pip` を Python 3.14 向け alias として定義する。

Snowflake workload identity の補足:

- `WORKLOAD_IDENTITY` は Snowflake の `TYPE = SERVICE` user 用であり、`TYPE = PERSON` user には設定できない。
- Snowflake user が持てる `WORKLOAD_IDENTITY` property は 1 つである。
- Workbench からの dbt 実行は、owner 単位の AWS IAM role に紐づく Workbench service user で行う。
- 人間用の `PERSON` user と Workbench service user は分離する。

### 5.4 手動操作の許容範囲

- IAM ポリシーで許可されている場合、EC2 コンソールからの stop/start は許容する。
- terminate/delete は Terraform ワークフロー境界に限定する。

### 5.5 タグベース所有者モデル

- すべての Workbench EC2 に最低限次のタグを付与する。
   - `Owner`（開発者識別子）
   - `Environment`（例: `dev`）
   - `Name`（表示用ラベル）
- アクセス制御は instance 名ではなく `Owner` タグ一致で判定する。

### 5.6 サポートセッション運用

- 通常モード: 所有者のみ自分のインスタンスへアクセス可能。
- サポートモード: 明示承認と監査ログ記録を条件に、一時的な他者アクセスを許可する。
- Session Manager のログは追跡可能性のため保存する。

### 5.7 アイデンティティ管理境界

- 人間の開発者ユーザのライフサイクル管理は Git 管理対象外。
- リポジトリ側ではロール/ポリシー境界と実行ワークフローを管理対象とする。

### 5.8 Snowflake 開発実行境界（現時点ルール）

- 正式スキーマ `DATAWAREHOUSE_DB.STAGING` と `DATAWAREHOUSE_DB.CORE` は、CI/CD 管理下の書き込み先として扱う。
- 非 CI/CD の開発者検証は、個人用カスタムスキーマ（例: `staging_<owner>`）でのみ実施する。
- 正式スキーマへの反映は Pull Request + CI/CD 実行を必須とする。
- 個人用開発スキーマは一時領域として扱い、定期的にクリーンアップする。
- この境界は将来見直し可能だが、現時点では CI/CD 優先保護を既定とする。

## 6. 関連ドキュメント

- [README.ja.md](../README.ja.md)
- [bootstrap/README.ja.md](../bootstrap/README.ja.md)
- [schemachange/README.ja.md](../schemachange/README.ja.md)
- [dbt](../dbt)