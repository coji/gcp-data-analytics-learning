# Phase 0-01: GCP CLI（gcloud, bq）の基本操作

## 📖 学習目標

Google Cloud Platform（GCP）をコマンドラインから操作するためのツールを習得する。

### このセクションで学ぶこと

- gcloud CLIの認証とプロジェクト設定
- bqコマンドでBigQueryを操作
- データセットとテーブルの作成・削除
- クエリの実行とデバッグ

## 📚 学習リソース

### 公式ドキュメント

- [gcloud CLIの概要](https://cloud.google.com/sdk/gcloud)
- [bqコマンドリファレンス](https://cloud.google.com/bigquery/docs/bq-command-line-tool)

### 実践的なチュートリアル

- [Google Cloud Skills Boost - BigQuery for Data Warehousing](https://www.cloudskillsboost.google/course_templates/624)

## 🚀 ハンズオン演習

### 前提条件

```bash
# gcloud CLIがインストールされていることを確認
gcloud --version

# インストールされていない場合（macOS）
brew install --cask google-cloud-sdk
```

### 🔄 複数アカウント使用時の注意

クライアントワークで複数のGCPアカウントを使い分けている方は、**学習用の設定に切り替えてから**演習を開始してください。

```bash
# 学習用設定に切り替え
gcloud config configurations activate learning-gcp

# 現在の設定を確認
gcloud config list

# 出力例:
# [core]
# account = YOUR_LEARNING_ACCOUNT@gmail.com
# project = YOUR_LEARNING_PROJECT_ID
```

詳細は [../../multi-account-setup.md](../../multi-account-setup.md) を参照してください。

### 演習1: 認証とプロジェクト設定

```bash
# 1. 認証
gcloud auth login

# 2. プロジェクト設定
gcloud config set project YOUR_PROJECT_ID

# 3. 現在の設定確認
gcloud config list
```

**結果を `exercises.md` に記録してください**

### 演習2: BigQueryデータセットの操作

```bash
# 1. データセット一覧を取得
bq ls --project_id=YOUR_PROJECT_ID

# 2. 特定のデータセットの詳細確認
bq show --format=prettyjson YOUR_PROJECT_ID:DATASET_NAME

# 3. テーブルのスキーマを確認
bq show --schema --format=prettyjson YOUR_PROJECT_ID:DATASET.TABLE
```

**実行したコマンドを `commands-log.sh` に保存してください**

### 演習3: クエリの実行

```bash
# 1. シンプルなクエリ
bq query --use_legacy_sql=false \
  'SELECT
    CURRENT_DATE() as today,
    "Hello BigQuery" as message'

# 2. 既存テーブルのクエリ（例）
bq query --use_legacy_sql=false \
  'SELECT date, SUM(cost) as total_cost
   FROM `YOUR_PROJECT_ID.DATASET.TABLE`
   WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
   GROUP BY date
   ORDER BY date DESC'

# 3. クエリのドライラン（実際には実行しない、スキャン量のみ確認）
bq query --use_legacy_sql=false --dry_run \
  'SELECT * FROM `YOUR_PROJECT_ID.DATASET.TABLE`'
```

### 演習4: テストデータセットの作成

```bash
# 1. データセットを作成
bq mk --dataset \
  --location=asia-northeast1 \
  --description="学習用テストデータセット" \
  YOUR_PROJECT_ID:learning_dev

# 2. データセットが作成されたか確認
bq ls --project_id=YOUR_PROJECT_ID

# 3. サンプルテーブルを作成
bq mk --table \
  YOUR_PROJECT_ID:learning_dev.test_table \
  id:INTEGER,name:STRING,created_at:TIMESTAMP

# 4. データを挿入
bq query --use_legacy_sql=false \
  'INSERT INTO `YOUR_PROJECT_ID.learning_dev.test_table` (id, name, created_at)
   VALUES (1, "Test User", CURRENT_TIMESTAMP())'

# 5. データを確認
bq query --use_legacy_sql=false \
  'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.test_table`'
```

### 演習5: クリーンアップ

```bash
# テストデータセットを削除（-r: 再帰的, -f: 強制）
bq rm -r -f YOUR_PROJECT_ID:learning_dev
```

## 🎯 サンプルデータで練習

学習用のオープンデータが利用可能です！詳細は[sample-data-guide.md](../../sample-data-guide.md)を参照してください。

### クイックスタート

```bash
# BigQueryの公開データセット（thelook_ecommerce）を使用
# 流入元別のセッション数を確認
bq query --use_legacy_sql=false \
  'SELECT
    traffic_source,
    COUNT(DISTINCT session_id) as sessions
   FROM `bigquery-public-data.thelook_ecommerce.events`
   WHERE DATE(created_at) = "2024-01-01"
   GROUP BY traffic_source
   ORDER BY sessions DESC'
```

## 📝 演習課題

以下の課題を `exercises.md` に記録してください：

### 課題1: データセットの調査

1. 自分のGCPプロジェクトのすべてのデータセットをリストアップ
2. 各データセットの説明を読み、役割を理解する
3. どのデータセットが最も大きいか調査する

### 課題2: 集計クエリの作成

既存のテーブル（またはサンプルテーブル）から、以下のクエリを作成：

1. 過去30日間の日別データを集計
2. カテゴリ別の合計値を計算
3. 上位10件のレコードを取得

### 課題3: データセットのコピー

1. 開発用のテストデータセットを作成
2. 既存のテーブルから1000件のサンプルデータをコピー
3. コピーしたデータを確認

## ✅ 完了チェックリスト

- [ ] gcloud CLIで認証完了
- [ ] プロジェクト設定完了
- [ ] データセット一覧の取得成功
- [ ] テーブルスキーマの確認成功
- [ ] クエリの実行成功
- [ ] `--dry_run`の使い方理解
- [ ] データセットの作成・削除成功
- [ ] 演習課題1完了
- [ ] 演習課題2完了
- [ ] 演習課題3完了

## 🔗 次のステップ

完了したら、[Phase 0-02: BigQuery高度な機能](../02-bigquery-advanced/README.md)に進んでください。

## 📌 参考コマンド集

### gcloud よく使うコマンド

```bash
# 認証情報の確認
gcloud auth list

# プロジェクト一覧
gcloud projects list

# デフォルト設定の確認
gcloud config list

# 特定の設定値を取得
gcloud config get-value project
```

### bq よく使うコマンド

```bash
# データセット作成
bq mk --dataset PROJECT_ID:DATASET_NAME

# テーブル作成
bq mk --table PROJECT_ID:DATASET.TABLE schema.json

# データのロード
bq load --source_format=CSV PROJECT_ID:DATASET.TABLE gs://bucket/file.csv

# データのエクスポート
bq extract PROJECT_ID:DATASET.TABLE gs://bucket/output.csv

# ジョブの確認
bq ls -j --max_results 10
```

## ❓ トラブルシューティング

### 認証エラーが出る

```bash
# 認証をリセット
gcloud auth revoke
gcloud auth login
```

### プロジェクトが見つからない

```bash
# 利用可能なプロジェクト一覧を確認
gcloud projects list

# プロジェクトIDを正確に設定
gcloud config set project CORRECT_PROJECT_ID
```

### BigQueryの権限エラー

- プロジェクトオーナーまたはBigQueryユーザーの権限が必要
- IAMで自分のアカウントに適切なロールが付与されているか確認
