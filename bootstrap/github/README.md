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

### 4. 【補足】1人2役検証のための事前準備

本リポジトリは承認数およびコードオーナー制限を厳格に有効化している。また本番環境は自己承認が禁止されているため、開発・検証段階において自分1人でプルリクエストをマージし、本番パイプラインの完走までテストするためには、以下の事前設定（1人2役のシミュレーション環境）が必要となる。

1. **Collaborators の招待**
* `Settings` ➔ `Collaborators` を開き、`Add people` ボタンから自身の別アカウント（例: `yusuke-shudo-member` 等）を招待する。
* 招待送信後、別アカウント側で GitHub にログインし、招待を承諾（Accept invitation）する。
* *※ 招待した別アカウントは、上記「3-2. 本番環境（Prd）用の作成」の `Required reviewers` にも必ず含めておくこと。*

2. **CODEOWNERS ファイルの配置**
* リポジトリのルート（または `.github/` ディレクトリ配下）に、**`CODEOWNERS`** という名前のファイルを以下の内容で作成し、事前に `main` ブランチへコミット（配置）しておく。
```text
# リポジトリ内のすべてのファイル(*)に対して、メインアカウントと検証用別アカウントの両方をコードオーナーとして強制指定
* @[メインアカウント名] @[検証用の別アカウント名]
# （具体的な記述例）
# * @yusuke-shudo @yusuke-shudo-member
```
