# スクリプト / Scripts

このディレクトリには、学習環境のセットアップと管理のためのシェルスクリプトが含まれています。

## 📜 スクリプト一覧

### 🚀 クイックスタート

#### **quickstart-sample-data.sh**
BigQuery公開データセットを使ってすぐに動作確認できるスクリプト。

**用途**: 環境構築前の動作確認、BigQueryの基本操作の確認

**実行内容**:
- BigQuery公開データセット（thelook_ecommerce）への接続確認
- サンプルクエリの実行
- 結果の表示

**使い方**:
```bash
# プロジェクトルートから実行
./scripts/quickstart-sample-data.sh
```

**必要な権限**: BigQuery利用権限（公開データセットは無料で使用可能）

---

### 🔧 学習環境セットアップ

#### **setup-learning-data.sh**
学習用データセットを自分のプロジェクトに作成するスクリプト。

**用途**: Phase 0-2のハンズオン演習用データの準備

**実行内容**:
1. 現在のgcloud設定を表示（安全確認）
2. `learning_dev` データセットの作成
3. BigQuery公開データからサンプルデータをコピー:
   - `events` - ユーザー行動イベント
   - `orders` - 注文データ
   - `order_items` - 注文明細
   - `users` - ユーザーマスタ
   - `products` - 商品マスタ
4. パーティション分割版テーブルの作成（`events_partitioned`）

**使い方**:
```bash
# プロジェクトルートから実行
./scripts/setup-learning-data.sh
```

**前提条件**:
- gcloud CLI認証済み
- BigQuery APIが有効化されている
- プロジェクトへの書き込み権限

**注意**:
- 実行前に現在のプロジェクト設定を確認してください
- 本番環境での実行は避けてください
- プロジェクトIDに "prod" や "production" が含まれる場合は警告が表示されます

---

### 🔄 アカウント切り替え

#### **switch-to-learning.sh**
複数のGCPアカウント・プロジェクトを使い分けている方向けの切り替えスクリプト。

**用途**: 学習用のgcloud configurationへの安全な切り替え

**実行内容**:
1. 学習用configuration（`learning-gcp`）の存在確認
2. 存在しない場合は対話的に作成
3. 学習用configurationへの切り替え
4. 現在の設定を表示

**使い方**:
```bash
# プロジェクトルートから実行
./scripts/switch-to-learning.sh
```

**初回実行時の入力項目**:
- 学習用のGoogleアカウント
- 学習用のGCPプロジェクトID

**利点**:
- クライアントワークと学習を安全に分離
- 設定ミスによる本番環境への影響を防ぐ
- ワンコマンドで学習環境に切り替え

---

## 📋 推奨実行順序

### 初回セットアップ

```bash
# 1. 複数アカウント使用時: 学習用設定に切り替え
./scripts/switch-to-learning.sh

# 2. 動作確認（公開データセットを使用）
./scripts/quickstart-sample-data.sh

# 3. 学習用データセットを作成
./scripts/setup-learning-data.sh
```

### 日常的な使用

```bash
# 学習を開始する前に毎回実行（複数アカウント使用時）
./scripts/switch-to-learning.sh

# 必要に応じてデータを再セットアップ
./scripts/setup-learning-data.sh
```

## 🔒 セキュリティ注意事項

### 実行前の確認事項

1. **現在のプロジェクトを確認**
   ```bash
   gcloud config get-value project
   ```

2. **本番環境でないことを確認**
   - プロジェクトIDに "prod", "production" が含まれていないか
   - クライアントのプロジェクトでないか

3. **学習用プロジェクトであることを確認**
   ```bash
   # 学習用設定の確認
   gcloud config configurations list
   ```

### エイリアス設定（推奨）

毎回スクリプトのパスを入力するのが面倒な場合は、エイリアスを設定できます:

```bash
# ~/.bashrc または ~/.zshrc に追加
alias gcp-learning='cd /path/to/gcloud && ./scripts/switch-to-learning.sh'
alias gcp-setup='cd /path/to/gcloud && ./scripts/setup-learning-data.sh'
```

詳細は [config/.aliases.example](../config/.aliases.example) を参照してください。

## 🆘 トラブルシューティング

### スクリプトが実行できない

```bash
# 実行権限を付与
chmod +x scripts/*.sh
```

### データセット作成エラー

```bash
# BigQuery APIが有効か確認
gcloud services list --enabled | grep bigquery

# 有効化されていない場合
gcloud services enable bigquery.googleapis.com
```

### 認証エラー

```bash
# 再認証
gcloud auth login
gcloud auth application-default login
```

## 🔙 戻る

- [プロジェクトルート](../) - README.mdへ
- [ドキュメント](../docs/) - 詳細ガイド
