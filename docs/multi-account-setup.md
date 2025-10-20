# 複数GCPアカウント・プロジェクトの管理

クライアントワークで複数のGCPアカウント・プロジェクトを使い分けている方向けのガイド。

## 🔄 gcloud設定の切り替え

### 現在の設定確認

```bash
# アクティブなアカウントとプロジェクトを確認
gcloud config list

# すべての設定（configurations）を確認
gcloud config configurations list
```

### 設定（Configuration）の作成と切り替え

gcloudでは「configuration」を使って、アカウントとプロジェクトのセットを管理できます。

```bash
# 学習用の設定を作成
gcloud config configurations create learning-gcp

# 設定をアクティブ化
gcloud config configurations activate learning-gcp

# アカウントとプロジェクトを設定
gcloud config set account YOUR_LEARNING_ACCOUNT@gmail.com
gcloud config set project YOUR_LEARNING_PROJECT_ID

# デフォルトリージョンも設定（任意）
gcloud config set compute/region asia-northeast1
gcloud config set compute/zone asia-northeast1-a
```

### よく使うコマンド

```bash
# 設定一覧
gcloud config configurations list

# 設定の切り替え
gcloud config configurations activate learning-gcp    # 学習用
gcloud config configurations activate client-a        # クライアントA
gcloud config configurations activate client-b        # クライアントB

# 現在の設定確認
gcloud config configurations describe learning-gcp

# 設定の削除
gcloud config configurations delete OLD_CONFIG
```

## 📋 推奨設定例

### 1. 学習用設定

```bash
gcloud config configurations create learning-gcp
gcloud config configurations activate learning-gcp

gcloud config set account your-personal@gmail.com
gcloud config set project your-learning-project
gcloud config set compute/region asia-northeast1
```

### 2. クライアントA用設定

```bash
gcloud config configurations create client-a
gcloud config configurations activate client-a

gcloud config set account you@client-a.com
gcloud config set project client-a-production
gcloud config set compute/region us-central1
```

### 3. クライアントB用設定

```bash
gcloud config configurations create client-b
gcloud config configurations activate client-b

gcloud config set account you@client-b.jp
gcloud config set project client-b-prod
gcloud config set compute/region asia-northeast1
```

## 🚀 学習用セットアップフロー

### 1. 学習用設定を作成・アクティブ化

```bash
# 学習用configurationが存在するか確認
gcloud config configurations list | grep learning-gcp

# 存在しない場合は作成
gcloud config configurations create learning-gcp

# アクティブ化
gcloud config configurations activate learning-gcp
```

### 2. 学習用アカウントで認証

```bash
# 認証（ブラウザが開く）
gcloud auth login

# 学習用アカウントでログイン
# -> ブラウザでアカウントを選択

# Application Default Credentials（ADC）も設定
gcloud auth application-default login
```

### 3. 学習用プロジェクトを設定

```bash
# プロジェクト設定
gcloud config set project YOUR_LEARNING_PROJECT_ID

# 確認
gcloud config list
```

### 4. BigQueryの認証確認

```bash
# BigQueryの接続テスト
bq ls --project_id=YOUR_LEARNING_PROJECT_ID

# 公開データセットへのアクセステスト
bq query --use_legacy_sql=false \
  'SELECT COUNT(*) FROM `bigquery-public-data.thelook_ecommerce.events` LIMIT 1'
```

## 🔧 このリポジトリでの学習開始

学習用設定にしてから、セットアップスクリプトを実行してください。

```bash
# 1. 学習用設定に切り替え
gcloud config configurations activate learning-gcp

# 2. 現在の設定確認
gcloud config list
# account = YOUR_LEARNING_ACCOUNT@gmail.com
# project = YOUR_LEARNING_PROJECT_ID

# 3. セットアップスクリプト実行
./setup-learning-data.sh
```

## 🔧 便利なスクリプト

### 学習用設定への切り替えスクリプト

```bash
# 学習用設定に切り替え（configurationが未作成の場合は作成もできる）
./switch-to-learning.sh
```

このスクリプトは：

- `learning-gcp` configurationが存在するか確認
- 存在しない場合は作成を提案
- 設定を切り替えて現在の状態を表示

## 💡 便利なエイリアス設定

`.bashrc` や `.zshrc` に追加すると便利です（`.aliases.example` 参照）：

```bash
# ~/.bashrc または ~/.zshrc

# gcloud設定の切り替えエイリアス
alias gcloud-learning='gcloud config configurations activate learning-gcp'
alias gcloud-client-a='gcloud config configurations activate client-a'
alias gcloud-client-b='gcloud config configurations activate client-b'

# 現在の設定確認
alias gcloud-current='gcloud config list'
alias gcloud-list='gcloud config configurations list'
```

設定後：

```bash
# エイリアスを使った切り替え
gcloud-learning      # 学習用に切り替え
gcloud-current       # 現在の設定確認

gcloud-client-a      # クライアントAに切り替え
gcloud-current       # 確認
```

## ⚠️ 注意事項

### 1. 誤ったプロジェクトでの操作を防ぐ

```bash
# スクリプト実行前に必ず確認
gcloud config list

# プロジェクトIDが正しいか確認してから実行
./setup-learning-data.sh
```

### 2. デフォルト設定の確認

```bash
# どの設定がデフォルト（IS_ACTIVE = True）か確認
gcloud config configurations list

# デフォルト設定の変更
gcloud config configurations activate DESIRED_CONFIG
```

### 3. 認証トークンの管理

各設定（configuration）は独立していますが、認証トークンは共有される場合があります。

```bash
# 認証済みアカウント一覧
gcloud auth list

# 特定のアカウントで再認証
gcloud auth login YOUR_ACCOUNT@example.com

# Application Default Credentialsも設定が必要な場合
gcloud auth application-default login
```

## 🔐 複数アカウントの認証状態

```bash
# すべての認証済みアカウントを確認
gcloud auth list

# 出力例:
#        Credentialed Accounts
# ACTIVE  ACCOUNT
# *       your-learning@gmail.com
#         you@client-a.com
#         you@client-b.jp

# アクティブなアカウントを切り替え
gcloud config set account you@client-a.com
```

## 📋 学習開始時のチェックリスト

- [ ] 学習用configurationを作成（`learning-gcp`）
- [ ] 学習用設定に切り替え（`gcloud config configurations activate learning-gcp`）
- [ ] 学習用アカウントで認証（`gcloud auth login`）
- [ ] 学習用プロジェクトを設定（`gcloud config set project YOUR_PROJECT`）
- [ ] BigQuery接続テスト（`bq ls`）
- [ ] 現在の設定を確認（`gcloud config list`）
- [ ] セットアップスクリプト実行（`./setup-learning-data.sh`）

## 🔗 関連リソース

- [gcloud configurations ドキュメント](https://cloud.google.com/sdk/gcloud/reference/config/configurations)
- [複数アカウントの管理](https://cloud.google.com/sdk/docs/configurations)

---

**設定を切り替えてから学習を開始しましょう！**
