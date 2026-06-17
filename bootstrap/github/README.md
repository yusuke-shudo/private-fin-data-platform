# GitHub 初期ブートストラップ手順

本手順は、GitHub リポジトリ（`private-fin-data-platform`）の初期作成後に、ローカル環境の同期設定、General 設定、ブランチ保護（Rulesets）、およびデータプラットフォーム環境（Environments/Variables）を手作業で構築するためのマニュアルである。

## 🏃‍♂️ GitHub での初期構築フロー

### 1. 基本設定とローカル環境の同期

1. **ローカル Git のデフォルトブランチ名統一**
* 自身のパソコン（ローカル環境）のターミナルを開き、以下のコマンドを一度だけ実行する。
```bash
git config --global init.defaultBranch main
```
* *※ ローカル Git が古い名残で `master` ブランチを自動生成するのを防ぎ、GitHub 側の標準である `main` と一貫性を持たせるための安全策である。*

2. **リポジトリの公開範囲（Visibility）の確認**
* リポジトリの `Settings` ➔ `General` セクションの最下部にある `Danger Zone` を確認する。
* **Change repository visibility**: **`Public`** になっていることを確認する。
* *※ GitHub Free プランにおいて、ブランチ保護や Ruleset などの高度なセキュリティ機能を有効化するためには、リポジトリが Public である必要がある。*

3. **プルリクエストのマージ方法制限**
* `Settings` ➔ `General` の `Pull Requests` セクションに移動し、マージ方法を以下のように制限する。
* **Allow merge commits**: 無効化（チェックを外す）
* **Allow squash merging**: 有効化（チェックを入れる）
* **Allow rebase merging**: 有効化（チェックを入れる）
* *※ これにより、コミット履歴が枝分かれせず、一本の美しい直線（Linear History）に保たれる。*

4. **マージ後ブランチの自動削除設定**
* 同じく `General` 画面の下部にある以下の項目を設定する。
* **Automatically delete head branches**: 有効化（チェックを入れる）
* *※ プルリクエストが `main` にマージされた瞬間、開発用ブランチが GitHub 側で自動的にクリーンアップされる。*


---

### 2. ブランチ保護（Rulesets）の設定

1. **Ruleset の新規作成**
* リポジトリの `Settings` ➔ `Rules` ➔ `Rulesets` を開く。
* `New ruleset` ➔ `Create a new ruleset` を選択する。

2. **基本情報の設定**
* 以下の内容を入力・設定する。
* **Ruleset Name**: `Protect main`
* **Enforcement status**: `Active`（有効）
* *※ 注意: **Bypass list** は意図的に空（Empty）のままにする。管理者であってもレビューなしの直接マージ（特権マージ）を禁止し、ガバナンスを徹底する。*

3. **対象ブランチの指定（Target branches）**
* `Target branches` セクションで、`Add target` ➔ `Include by name` を選択する。
* フォームに **`main`** と入力して追加する。
* 画面上で「Applies to 1 target: main」と表示されていることを確認する。

4. **制限ルールの有効化（Branch rules）**
* `Branch rules` セクションに移動し、以下の項目をチェックして厳格に設定する。
* **`Require a pull request before merging`**
* **Required approvals**: `1` を指定（マージに最低1人の承認レビューを必須化）
* **`Dismiss stale pull request approvals...`**: 有効化（新しいコミットがプッシュされたら、古い承認を自動で取り消す）
* **`Require review from Code Owners`**: 有効化（CODEOWNERS ファイルに定義された責任者の承認を必須化）
* **`Require conversation resolution before merging`**: 有効化（PR 内のコメントや指摘スレッドがすべて「Resolved」になるまでマージをブロック）
* **`Allowed merge methods`**
* **Allow merge commits**: 無効化
* **Allow squash merging**: 有効化
* **Allow rebase merging**: 有効化
* 画面最下部の `Create` ボタンを押して保存する。


---

### 3. 環境（Environments）と変数（Variables）の作成

> 💡 **環境を4つに分ける理由**
> Snowflake のセキュリティ制限により、「同一の OIDC Subject（GitHub の環境名やブランチ名）」を複数の統合オブジェクトに重複して登録することができない。これを回避するため、インフラ（Terraform）用とデータ（dbt）用で「環境 × 役割」の計 4 つの Environment を個別に定義する。

1. **開発環境（Dev）用の作成と変数登録**
* `Settings` ➔ `Environments` を開き、以下の 2 つの環境をそれぞれ作成する。
1. **`dev-infra`** （Terraform インフラ用）
2. **`dev-data`** （dbt データ加工用）
* 作成後、**両方の環境** の画面下部（Environment variables）で、それぞれ共通して以下の 4 つの変数を登録する。
* `AWS_ACCOUNT_ID`: `[dev用の12桁のAWSアカウントID]`
* `PROJECT_PREFIX`: `yskshd-fin-data`
* `SF_ORGANIZATION_NAME`: `[Snowflakeの組織名]`
* `SF_ACCOUNT_NAME`: `[dev用のSnowflakeアカウント名]`

2. **本番環境（Prd）用の作成と承認ルールの追加**
* 同様に、`Environments` 画面で以下の 2 つの環境を作成する。
1. **`prd-infra`** （Terraform インフラ用）
2. **`prd-data`** （dbt データ加工用）
* **重要（安全弁・組織統制の設定）**: `prd-infra` と `prd-data` の両方の環境で、以下のデプロイ保護ルールを設定する。
* 🟦 **`Required reviewers`** にチェックを入れる。
* **対象者の指定**: 本番デプロイの承認権限を持つメンバー（**2名以上の複数名**、または承認用チーム）を検索してすべて追加する。
* 🟦 **`Prevent self-review`** にチェックを入れる（デプロイの実行者自身による承認を禁止し、相互レビューを強制する）。
* 🟩 **`Allow administrators to bypass configured protection rules`** の**チェックを外す（無効化）**。
* *※ 注意: 最後のチェックを外すことで、リポジトリの管理者（Admin）であってもルールの回避が不可能になり、特権ユーザーによる単独の本番変更を完全にロックアウトできる。*
* 作成後、両方の環境の画面下部で以下の 4 つの変数を登録する（値は本番用のものに書き換える）。
* `AWS_ACCOUNT_ID`: `[prd用の12桁のAWSアカウントID]`
* `PROJECT_PREFIX`: `yskshd-fin-data`
* `SF_ORGANIZATION_NAME`: `[Snowflakeの組織名]`
* `SF_ACCOUNT_NAME`: `[prd用のSnowflakeアカウント名]`


---

---

### 4. 【補足】1人2役（マルチアカウント）での開発・本番デプロイ検証手順

本リポジトリは、ブランチ保護（Rulesets）による「CODEOWNERS 承認の必須化」および、本番環境（Environments）による「自己承認の禁止（Prevent self-review）」「管理者バイパスの禁止」を徹底した厳格なガバナンスを設定している。

そのため、開発・検証段階において**自分1人でプルリクエストをマージし、本番環境へのデプロイまでを完走テストするためには、以下の「1人2役（マルチアカウント）環境」の事前準備と運用フローが必要**となる。

#### 4-1. 事前準備：検証用サブアカウントのセットアップ

1. **Collaborators の招待と承諾**
   * メインアカウントで `Settings` ➔ `Collaborators` を開き、`Add people` ボタンから自身の検証用サブアカウント（例: `yusuke-shudo-member`）を招待する。
   * **重要**: 招待送信後、シークレットブラウザ等でサブアカウントにログインし、必ず招待を承諾（Accept invitation）させておくこと。

2. **本番環境のレビュアー（Required reviewers）への追加**
   * `Settings` ➔ `Environments` ➔ `prd-infra` および `prd-data` の設定画面に移動する。
   * `Required reviewers` の対象に、招待した**サブアカウント**を必ず追加する。

3. **CODEOWNERS ファイルの配置**
   * リポジトリのルート（または `.github/` ディレクトリ配下）に、**`CODEOWNERS`** という名前のファイルを以下の内容で作成し、あらかじめ `main` ブランチへコミット（配置）しておく。

```text
# AWS側のコードオーナー
/terraform/aws/            @[メインアカウント名] @[検証用の別アカウント名]

# Snowflake側のコードオーナー
/terraform/snowflake/      @[メインアカウント名] @[検証用の別アカウント名]


# （具体的な記述例）
# # AWS側のコードオーナー
# /terraform/aws/            @yusuke-shudo @yusuke-shudo-member
# # Snowflake側のコードオーナー
# /terraform/snowflake/      @yusuke-shudo @yusuke-shudo-member
```

> 💡 **両方のアカウントを並べる理由**
> どちらのアカウントからプルリクエスト（PR）を作成した場合でも、もう片方のアカウントが該当ディレクトリの「Code Owner」としての資格を満たし、相互にレビュー承認を可能にするための設定である。

---

#### 4-2. 1人2役での検証運用ライフサイクル（開発から本番デプロイまで）

実際にコードを修正し、本番環境へ反映させる際は、以下のステップを踏んで1人2役の検証を行う。

| ステップ | 実行アカウント | 操作内容 | 実行されるトリガー |
| :--- | :---: | :--- | :--- |
| **1. PR作成** | **メイン** | トピックブランチから `main` ブランチへのプルリクエスト（PR）を作成する。 | 自動で **AWS/SFの Plan** が起動 |
| **2. コード承認** | **サブ** | サブアカウントでGitHubにログインし、PRの `Files changed` ➔ `Review changes` から **`Approve`（承認）** を実行する。 | CODEOWNERSの制約をクリア |
| **3. マージ** | **メイン** | PR画面に戻り、`Squash and merge`（または `Rebase and merge`）を実行する。 | `main` へマージされ、**dev環境への Apply** が自動起動 |
| **4. 本番デプロイ待ち**| — | dev環境のApplyが正常終了すると、次のジョブ（prd環境）が起動し、**「Deployment Review」の承認待ち（保留状態）** になる。 | パイプラインが一時停止 |
| **5. 本番承認** | **サブ** | GitHub Actionsの実行画面、またはPR画面に表示される `Review deployments` を押し、`prd-infra`（または `prd-data`）へのデプロイを **`Approve`（承認）** する。 | **prd環境への Apply** が起動し、本番反映が完了！ |

> ⚠️ **注意点**
> ステップ5において、メインアカウント自身で本番デプロイを承認しようとすると、`Prevent self-review` ルールによって拒否される。必ずサブアカウントに切り替えて承認を行うこと。
