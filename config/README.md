# 設定ファイル / Configuration Files

このディレクトリには、学習環境を便利にするための設定ファイル例が含まれています。

## 📄 ファイル一覧

### .aliases.example

GCP学習用のシェルエイリアス設定例。

**用途**: よく使うコマンドを短縮して効率化

**含まれるエイリアス**:

#### gcloud configuration切り替え
- `gcloud-learning` - 学習用configurationに切り替え
- `gcloud-client-a` - クライアントA用に切り替え（コメントアウト）
- `gcloud-client-b` - クライアントB用に切り替え（コメントアウト）

#### 現在の設定確認
- `gcloud-current` - 現在のgcloud設定を表示
- `gcloud-list` - すべてのconfiguration一覧
- `gcloud-whoami` - アクティブなアカウントを確認
- `gcloud-project` - アクティブなプロジェクトを確認

#### BigQuery便利コマンド
- `bq-datasets` - 現在のプロジェクトのデータセット一覧
- `bq-learning` - learning_devデータセットのテーブル一覧

#### 学習用クイックスタート（コメントアウト）
- `cdgcp` - 学習用ディレクトリに移動
- `gcp-setup` - 学習用設定に切り替えてセットアップ

## 🚀 使い方

### 1. ファイルをコピー

```bash
# ホームディレクトリの設定ファイルに追記
cat config/.aliases.example >> ~/.bashrc    # Bashの場合
# または
cat config/.aliases.example >> ~/.zshrc     # Zshの場合
```

### 2. カスタマイズ

必要に応じてエイリアスを編集:

```bash
# エディタで開く
vim ~/.bashrc  # または ~/.zshrc

# コメントアウトされているエイリアスを有効化
# 例:
# alias gcloud-client-a='...'  # コメントアウト状態
alias gcloud-client-a='...'    # 有効化

# パスを環境に合わせて変更
alias cdgcp='cd ~/path/to/gcloud'  # 実際のパスに変更
```

### 3. 設定を反映

```bash
# 設定を再読み込み
source ~/.bashrc  # Bashの場合
# または
source ~/.zshrc   # Zshの場合

# またはターミナルを再起動
```

## 📝 使用例

### 基本的な使い方

```bash
# 学習用に切り替え
$ gcloud-learning
Activated configuration [learning-gcp].
account = your-learning@gmail.com
project = your-learning-project

# 現在の設定確認
$ gcloud-current
[core]
account = your-learning@gmail.com
project = your-learning-project

# すべてのconfiguration確認
$ gcloud-list
NAME          IS_ACTIVE  ACCOUNT                    PROJECT
learning-gcp  True       your-learning@gmail.com    your-learning-project
client-a      False      you@client-a.com           client-a-project

# learning_devのテーブル一覧
$ bq-learning
         tableId          Type    Labels   Time Partitioning
 ----------------------- ------- -------- -------------------
  events                  TABLE
  orders                  TABLE
  order_items             TABLE
  users                   TABLE
  products                TABLE
  events_partitioned      TABLE            DAY
```

### 複数アカウントを使い分ける場合

```bash
# クライアントAのプロジェクトで作業
$ gcloud-client-a

# 作業完了後、学習用に戻る
$ gcloud-learning

# 誤って本番環境で作業しないよう、常に確認
$ gcloud-project
your-learning-project  # ← 学習用であることを確認
```

## 💡 カスタマイズのアイデア

### 複数クライアントの管理

```bash
# ~/.bashrc または ~/.zshrc に追加

# クライアント用のエイリアスを追加
alias gcloud-client-a='gcloud config configurations activate client-a && gcloud config list'
alias gcloud-client-b='gcloud config configurations activate client-b && gcloud config list'
alias gcloud-client-c='gcloud config configurations activate client-c && gcloud config list'

# 安全確認のためのエイリアス
alias gcloud-safe='gcloud config get-value project | grep -v "prod\|production" && echo "✅ Safe to work" || echo "⚠️  CAUTION: Production project!"'
```

### プロジェクト固有のエイリアス

```bash
# 学習プロジェクトのBigQueryに接続
alias bq-learn='bq query --use_legacy_sql=false'

# dbtコマンドのショートカット
alias dbt-dev='dbt run --target dev'
alias dbt-check='dbt test && dbt run'

# Terraformショートカット
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
```

### よく使うクエリのエイリアス

```bash
# イベント数の確認
alias bq-event-count='bq query --use_legacy_sql=false "SELECT COUNT(*) as count FROM \`$(gcloud config get-value project).learning_dev.events\`"'

# 今日のトラフィックソース別セッション数
alias bq-today-traffic='bq query --use_legacy_sql=false "SELECT traffic_source, COUNT(DISTINCT session_id) as sessions FROM \`$(gcloud config get-value project).learning_dev.events\` WHERE DATE(created_at) = CURRENT_DATE() GROUP BY traffic_source"'
```

## ⚠️ 注意事項

1. **パスワードや認証情報を含めない**
   - エイリアスにはプロジェクトIDやアカウント名のみ
   - パスワード、APIキー、トークンは絶対に含めない

2. **バージョン管理に注意**
   - この `.aliases.example` ファイルはGitにコミット可能
   - 実際の `~/.bashrc` や `~/.zshrc` は個人情報を含むため共有しない

3. **定期的な見直し**
   - 使わなくなったエイリアスは削除
   - プロジェクトが変わったら設定を更新

## 🔙 戻る

- [プロジェクトルート](../) - README.mdへ
- [複数アカウント管理ガイド](../docs/multi-account-setup.md) - 詳細な設定方法
