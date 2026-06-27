# AWS 初期ブートストラップ手順（管理アカウント）

- English version: [README.md](README.md)

本手順は、AWS の管理アカウント（Root/親アカウント）にログインし、マルチアカウント環境の土台（AWS Organizations / IAM Identity Center / StackSets）を手作業で構築するためのマニュアルである。

## 🏃‍♂️ 管理アカウントでの初期構築フロー

### 1. 認証と組織の土台構築

1. **Root ユーザーの保護**
* 管理アカウントの Root ユーザーにログインし、速やかに MFA（多要素認証）を設定する。

2. **AWS Organizations の有効化確認**
* AWS Organizations サービス画面を開き、組織が有効化されていることを確認する。

3. **AWS IAM Identity Center の有効化**
* IAM Identity Center サービス画面を開き、有効化（Enable）ボタンを押す。
* ※ データ保存リージョンは、主に使用するリージョン（例: `ap-northeast-1` 東京）を選択する。

4. **共通管理者グループ（Group）の作成**
* `Groups` ➔ `Create group` を選択し、以下の内容で作成する。
* **グループ名**: `Administrators`
* **説明**: `Group for users with full administrative access across accounts`

5. **許可セット（Permission Set）の作成**
* `Permission sets` ➔ `Create permission set` を選択する。
* 事前定義された許可セット（Predefined permission set）から **`AdministratorAccess`** を選択して作成する。

6. **作業用ユーザー（User）の作成**
* `Users` ➔ `Add user` からユーザー（例: `yusuke_shudo`）を作成し、先ほど作成した **`Administrators`** グループに追加する。

7. **AWS アカウントへのアクセス権紐付け**
* `AWS accounts` メニューを開き、組織内のアカウントに対してグループ `Administrators` と許可セット `AdministratorAccess` を紐付ける。

8. **組織単位（OU: Organizational Unit）の階層構築**
* AWS Organizations の画面を開く。
* ルート（Root）を選択し、`Actions` ➔ `Create new` ➔ `Organizational unit` から親OUを作成する。
* **OU名**: `Private`
* **説明**: `OU for personal financial data platform workloads`
* 作成した `Private` OU を選択し、その配下に子OUを2つ新規作成する。
* **子OU名（開発用）**: `Dev`
* **子OU名（本番用）**: `Prd`


---

### 2. 自動デプロイ（StackSets）の仕込み

> ⚠️ **注意**
> StackSets のターゲットは親である `Private` OU ではなく、新設した子OU（`Dev` / `Prd`）それぞれの OU ID を個別に指定すること。親OUを指定すると、開発用の設定が本番アカウントへ誤って自動デプロイされる原因となる。

1. **開発環境（Dev）用 StackSet の展開**
* `CloudFormation` ➔ `StackSets` ➔ `Create StackSet` を選択する。
* **テンプレート**: `bootstrap/aws/templates/fin-data-tfstate-base.yaml` をアップロードする。
* **StackSet名**: `fin-data-tfstate-base-dev`
* **パラメータ（Environment）**: `dev`
* **展開先**: `Deploy to organizational units (OUs)` を選択し、子OU **`Dev` の OU ID**（`ou-xxxx-xxxx`）を入力する。
* **リージョン**: メインリージョン（例: `ap-northeast-1`）を指定する。
* **自動展開（Auto Deployment）**: **`Enabled`** に設定する。

2. **本番環境（Prd）用 StackSet の展開**
* 同様に 2 つ目の StackSet を新規作成する。
* **テンプレート**: 同じファイルをアップロードする。
* **StackSet名**: `fin-data-tfstate-base-prd`
* **パラメータ（Environment）**: `prd`
* **展開先**: 子OU **`Prd` の OU ID**（`ou-yyyy-yyyy`）を入力する。
* **リージョン**: メインリージョン（例: `ap-northeast-1`）を指定する。
* **自動展開（Auto Deployment）**: **`Enabled`** に設定する。


---

### 3. 子アカウントの作成と初期設定

開発環境（DEV）と本番環境（PRD）でそれぞれ以下の一連のステップを順に実行する。

#### 3-1. 開発環境（DEV）のセットアップ

1. **AWS アカウントの作成**
* 管理アカウントの AWS Organizations 画面を開き、`Add an AWS account` ➔ `Create an AWS account` を選択する。
* **AWS アカウント名**: `fin-data-platform-dev`
* **メールアドレス**: `xxxxxx+aws-fin-data-platform-dev@yourdomain.com`

2. **ルートユーザーの事前保護（セーフティネットの確保）**
* 新規作成された子アカウントのルートユーザーは初期パスワードがないため、一度 AWS サインイン画面（ルートユーザー）にアクセスし、「パスワードをお忘れの場合」からパスワードを設定する。
* 設定したパスワードで子アカウントにサインインし、**IAM ダッシュボード** からルートユーザーの **MFA（多要素認証）** を有効化する。
* *※ MFA の秘密鍵（QRコード）や認証コードは、普段使わないため 1Password 等のパスワードマネージャーに安全に保管する。*
* 設定完了後、子アカウントからサインアウトする。

3. **ターゲット OU への移動（自動デプロイの発火）**
* 管理アカウントの AWS Organizations 画面に戻る。
* 作成した `fin-data-platform-dev` アカウントを選択して「移動」を押し、子OU **`Private/Dev`** の中へ移動させる。
* *※ 移動が完了した瞬間、仕込んでおいた StackSets が自動検知し、裏側で dev 用の S3 バケットと IAM ロールが安全に自動生成される。*


#### 3-2. 本番環境（PRD）のセットアップ

1. **AWS アカウントの作成**
* 同様に AWS Organizations の画面で `Create an AWS account` を選択する。
* **AWS アカウント名**: `fin-data-platform-prd`
* **メールアドレス**: `xxxxxx+aws-fin-data-platform-prd@yourdomain.com`

2. **ルートユーザーの事前保護**
* DEV と同様に、本番アカウントのルートユーザーのパスワード設定および **MFA（多要素認証）** の有効化を完了させる。完了後はサインアウトする。

3. **ターゲット OU への移動（自動デプロイの発火）**
* 管理アカウントに戻り、作成した `fin-data-platform-prd` アカウントを選択して、子OU **`Private/Prd`** の中へ移動させる。
* *※ 移動完了と同時に StackSets が自動発火し、prd 用の S3 バケット（S3 オブジェクトロック付き）と IAM ロールが自動生成される。*
