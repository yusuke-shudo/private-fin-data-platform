# GitHub 初期ブートストラップ手順

この手順は、GitHubリポジトリ（private-fin-data-platform）の初期作成後に、ローカル環境の同期設定、General設定、ブランチ保護（Rulesets）、およびデータプラットフォーム環境（Environments/Variables）を手作業で構築するためのマニュアルです。

## 🏃‍♂️ GitHubでの手作業手順

### 0. 【重要】ローカル環境とリポジトリの基本設定
- [ ] **1. ローカルGitのデフォルトブランチ名の統一**
  - ご自身のパソコン（ローカル環境）のターミナルを開き、以下のコマンドを1回実行します。
    ```bash
    git config --global init.defaultBranch main
    ```
  - ※注意: GitHub側は `main` が標準ですが、ローカルのGitは古い名残で `master` を作ってしまうことがあります。この設定により、ローカルでも一貫して `main` ブランチが作られるようになり、環境間の名前のズレを防ぎます。

- [ ] **2. リポジトリの公開範囲（Visibility）の確認**
  - リポジトリの `Settings` ➔ `General` セクションの最下部にある `Danger Zone` を確認します。
  - **Change repository visibility**: **`Public`** になっていることを確認します。
  - ※注意: GitHub Freeプランにおいて、ブランチ保護やRulesetなどの細かいセキュリティ機能を有効化するためには、リポジトリが Public である必要があります。

- [ ] **3. プルリクエストの制限（Pull Requests）**
  - `Pull Requests` セクションに移動し、マージ方法を以下のように制限・設定します。
  - **Allow merge commits**: 🟩 **無効（チェックを外す）**
  - **Allow squash merging**: 🟦 **有効（チェックを入れる）**
  - **Allow rebase merging**: 🟦 **有効（チェックを入れる）**
  - ※これにより、コミット履歴が一本の美しい直線（Linear History）に保たれます。

- [ ] **4. マージ後ブランチの自動削除（Pulls Branch Management）**
  - 同じく画面下部にある以下の項目にチェックを入れます。
  - **Automatically delete head branches**: 🟦 **有効（チェックを入れる）**
  - ※これにより、プルリクエストが `main` にマージされた瞬間、開発用のブランチがGitHub側で自動的にクリーンアップ（削除）されます。

---

### 1. ブランチ保護（Rulesets）の設定
- [ ] **5. Ruleset の新規作成**
  - リポジトリのトップ画面から `Settings` ➔ `Rules` ➔ `Rulesets` を開きます。
  - `New ruleset` ➔ `Create a new ruleset` を選択します。

- [ ] **6. 基本情報の設定**
  - **Ruleset Name**: `Protect main`
  - **Enforcement status**: `Active`（有効）
  - ※注意: **Bypass list** は意図的に空（Empty）のままにします。管理者であってもレビューなしの直接マージ（特権マージ）を禁止し、ガバナンスを徹底します。

- [ ] **7. 対象ブランチの指定（Target branches）**
  - `Target branches` セクションで、`Add target` ➔ `Include by name` を選択します。
  - フォームに **`main`** と明示的に入力して追加します。
  - ※画面上で「Applies to 1 target: main」と表示されていることを確認します。

- [ ] **8. プルリクエスト（PR）およびコードオーナー制限の有効化（Rules）**
  - `Branch rules` セクションに移動し、以下の項目を厳格に設定します。
  - 🟦 **`Require a pull request before merging`** にチェックを入れます。
    - **Required approvals**: **`1`** を指定します（マージに最低1人の承認レビューを必須化）。
    - 🟦 **`Dismiss stale pull request approvals when new commits are pushed`** にチェックを入れます（新しいコミットがプッシュされたら、古い承認を自動で取り消す安全弁）。
    - 🟦 **`Require review from Code Owners`** にチェックを入れます（CODEOWNERSファイルに定義された責任者の承認を必須化）。
    - 🟦 **`Require conversation resolution before merging`** にチェックを入れます（PR内のコメントや指摘スレッドがすべて「Resolved」になるまでマージをブロック）。
  - 🟦 **`Allowed merge methods`** にチェックを入れます（Rulesetレベルでのマージ方法の強制）。
    - **Allow merge commits**: 🟩 **無効（チェックを外す）**
    - **Allow squash merging**: 🟦 **有効（チェックを入れる）**
    - **Allow rebase merging**: 🟦 **有効（チェックを入れる）**
  - 画面最下部の `Create` ボタンを押して保存します。

---

### 2. 環境（Environments）と変数（Variables）の作成
AWSおよびSnowflakeのマルチアカウント構成（dev/prd）を安全に制御するため、2つの環境をリポジトリ内に定義します。

- [ ] **9. 開発環境（dev）の作成と変数登録**
  - `Settings` ➔ `Environments` を開き、右上の `New environment` を押し、Nameに **`dev`** と入力して作成します。
  - 画面下部の `Environment variables` ➔ `Add variable` を押し、以下の4つの変数を登録します。
    - `AWS_ACCOUNT_ID`: `[dev用の12桁のAWSアカウントID]`
    - `PROJECT_PREFIX`: `yskshd-fin-data`
    - `SF_ORGANIZATION_NAME`: `[Snowflakeの組織名]`
    - `SF_ACCOUNT_NAME`: `[dev用のSnowflakeアカウント名]`

- [ ] **10. 本番環境（prd）の作成と承認ルールの追加**
  - 再び `Environments` 画面に戻り、`New environment` を押し、Nameに **`prd`** と入力して作成します。
  - **Deployment protection rules** セクションの **`Required reviewers`** にチェックを入れ、ご自身のGitHubアカウント（または客先の承認者）を指定します（これにより、本番への自動デプロイ前に人間の承認ボタンが強制されます）。
  - `dev` と同様に、画面下部で以下の4つの変数を登録します（値は本番用のものに書き換えます）。
    - `AWS_ACCOUNT_ID`: `[prd用の12桁のAWSアカウントID]`
    - `PROJECT_PREFIX`: `yskshd-fin-data`
    - `SF_ORGANIZATION_NAME`: `[Snowflakeの組織名]`
    - `SF_ACCOUNT_NAME`: `[prd用のSnowflakeアカウント名]`

---

## 🛠️ 【補足】1人2役検証のための事前準備

承認数（Required approvals）およびコードオーナー制限を有効化しているため、開発中のプルリクエストをマージするためには以下の事前準備が必要です。

- [ ] **A. Collaboratorsの招待**
  - `Settings` ➔ `Collaborators` を開き、`Add people` ボタンから別アカウント（例: `yusuke-shudo-member`）を招待します。別アカウント側で招待を承諾（Accept invitation）してください。

- [ ] **B. CODEOWNERS ファイルの配置**
  - リポジトリのルート（または `.github/` ディレクトリ配下）に、**`CODEOWNERS`** という名前のファイルを以下の内容で作成し、事前に配置（コミット）しておきます。
  - ```text
    # リポジトリ内のすべてのファイル(*)に対して、この2人をコードオーナーとして強制指定
    * @yusuke-shudo @yusuke-shudo-member
    ```
