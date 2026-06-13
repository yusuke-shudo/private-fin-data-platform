# AWS 初期ブートストラップ手順（管理アカウント）

この手順は、AWSの管理アカウント（Root/親アカウント）にログインし、マルチアカウント環境の土台（AWS Organizations / IAM Identity Center / StackSets）を手作業で構築するためのマニュアルです。

## 🏃‍♂️ 管理アカウントでの手作業手順

### 1. 認証と組織の土台構築
- [ ] **1. Rootユーザーの保護**
  - 管理アカウントのRootユーザーにログインし、速やかにMFA（多要素認証）を設定します。
- [ ] **2. AWS Organizations の確認**
  - AWS Organizations サービスを開き、有効化されていることを確認します。
- [ ] **3. AWS IAM Identity Center の有効化**
  - IAM Identity Center サービスを開き、有効化（Enable）ボタンを押します。
  - ※データが保存されるリージョンは、主に使用するリージョン（例: `ap-northeast-1`）を選択してください。
- [ ] **4. 共通グループ（Group）の作成**
  - グループ名: `Administrators` を作成します。
  - 説明: `Group for users with full administrative access across accounts`
- [ ] **5. 許可セット（Permission Set）の作成**
  - `Permission sets` ➔ `Create permission set` から、事前定義されたポリシー **`AdministratorAccess`** を選択して作成します。
- [ ] **6. ユーザー（User）の作成**
  - Username: `yusuke_shudo` を作成し、**`Administrators`** グループに追加します。
- [ ] **7. アカウントへのアクセス権紐付け（AWS Accounts）**
  - `AWS accounts` メニューから、グループ `Administrators` に許可セット `AdministratorAccess` を紐付けます。
- [ ] **8. 組織単位（OU: Organizational Unit）の作成**
  - AWS Organizations の画面を開きます。
  - ルート（Root）を選択し、`Actions` ➔ `Create new` ➔ `Organizational unit` を選択します。
  - OU名: **`Private`**
  - 説明: `OU for personal financial data platform workloads`

### 2. 自動デプロイ（StackSets）の仕込み
- [ ] **9. AWS Organizations StackSets の展開（dev用）**
  - `CloudFormation` ➔ `StackSets` ➔ `Create StackSet` を選択します。
  - **テンプレートの指定**: `bootstrap/aws/templates/fin-data-tfstate-base.yaml` をアップロードします。
  - **StackSet名とパラメータ**: 
    - StackSet名: `fin-data-tfstate-base-dev`
    - パラメータ `Environment`: **`dev`**
  - **展開オプションの設定**:
    - 展開先: **`Deploy to organizational units (OUs)`** を選択し、先ほど作成した **`Private` OU のID** を入力します。
    - リージョン: メインリージョン（例: `ap-northeast-1`）を指定。
  - **自動展開（重要）**: **`Automatic deployment` を `Enabled`** に設定します。
- [ ] **10. AWS Organizations StackSets の展開（prd用）**
  - まったく同様の手順で2つ目のStackSetを新規作成します。
  - **StackSet名とパラメータ**: 
    - StackSet名: `fin-data-tfstate-base-prd`
    - パラメータ `Environment`: **`prd`**
  - **展開オプション・自動展開**: 同じく **`Private` OU** をターゲットにし、**`Automatic deployment` を `Enabled`** に設定します。

### 3. 子アカウントの作成（発火）
- [ ] **11. 開発環境（DEV）用のAWSアカウント作成**
  - AWS Organizations の画面を開き、先ほど作成した **`Private` OU** を選択した状態で `Add an AWS account` ➔ `Create an AWS account` を選択します。
  - AWS アカウント名: **`fin-data-platform-dev`**
  - メールアドレス: `admin+dev@yourdomain.com`
  - ※`Private` OUの中に直接作成されるため、作成が完了した瞬間にStep 2のStackSetが自動発火し、dev用のS3バケットとIAMロールが裏側で自動生成されます。
- [ ] **12. 本番環境（PRD）用のAWSアカウント作成**
  - 同様に **`Private` OU** を選択した状態で `Create an AWS account` を選択します。
  - AWS アカウント名: **`fin-data-platform-prd`**
  - メールアドレス: `admin+prd@yourdomain.com`
  - ※作成完了と同時に、prd用のS3バケット（S3ネイティブロック付き）とIAMロールが自動生成されます。
