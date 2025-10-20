# Phase 0-02: BigQuery 高度な機能

## 📖 学習目標

BigQueryのパーティショニング、クラスタリング、外部テーブル、IAM権限設計など、大規模データを効率的に扱うための機能を習得する。

### このセクションで学ぶこと

- パーティション分割テーブル（コスト削減）
- クラスター化テーブル（クエリ高速化）
- 外部データソース（GCS連携）
- IAM権限設計の基礎

## 📚 学習リソース

### 公式ドキュメント

- [パーティション分割テーブル](https://cloud.google.com/bigquery/docs/partitioned-tables)
- [クラスター化テーブル](https://cloud.google.com/bigquery/docs/clustered-tables)
- [外部データソース](https://cloud.google.com/bigquery/docs/external-data-sources)
- [BigQuery IAM](https://cloud.google.com/bigquery/docs/access-control)

### 推奨コース

- [Coursera - Modernizing Data Lakes and Data Warehouses with GCP](https://www.coursera.org/learn/data-lakes-data-warehouses-gcp)

## 🎓 重要な概念

### パーティショニング

日付や時刻のカラムでテーブルを分割し、クエリ時に必要な期間のみスキャン。

```sql
CREATE TABLE `project.dataset.table`
(
  date DATE NOT NULL,
  cost FLOAT64,
  impressions INT64
)
PARTITION BY date
OPTIONS(
  partition_expiration_days = 90  -- 90日後に自動削除
);
```

### クラスタリング

よく検索されるカラムでデータを物理的に並べ替える。

```sql
CREATE TABLE `project.dataset.table`
(
  date DATE NOT NULL,
  account_id STRING,
  campaign_id STRING,
  cost FLOAT64
)
PARTITION BY date
CLUSTER BY account_id, campaign_id;
```

### 外部テーブル

GCSに保存されたParquetファイルなどを、BigQueryから直接クエリ可能にする。

```sql
CREATE OR REPLACE EXTERNAL TABLE `project.dataset.external_table`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://bucket/path/*.parquet']
);
```

## 🚀 ハンズオン演習

### 演習1: パーティション分割テーブルの作成

```bash
# 1. テスト用データセット作成
bq mk --dataset --location=asia-northeast1 YOUR_PROJECT_ID:learning_dev

# 2. パーティション分割テーブル作成
bq mk --table \
  --time_partitioning_field=date \
  --time_partitioning_type=DAY \
  --time_partitioning_expiration=7776000 \
  --clustering_fields=media_source,campaign_id \
  YOUR_PROJECT_ID:learning_dev.test_ads_report \
  date:DATE,media_source:STRING,campaign_id:STRING,cost:FLOAT64,impressions:INT64

# 3. サンプルデータ挿入
bq query --use_legacy_sql=false \
  'INSERT INTO `YOUR_PROJECT_ID.learning_dev.test_ads_report` (date, media_source, campaign_id, cost, impressions)
   VALUES
     (CURRENT_DATE(), "platform_a", "camp001", 10000, 50000),
     (DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), "platform_a", "camp001", 12000, 60000)'

# 4. クエリ実行（パーティションフィルタあり）
bq query --use_legacy_sql=false --dry_run \
  'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.test_ads_report`
   WHERE date = CURRENT_DATE()'

# 5. パーティションフィルタなし（スキャン量比較）
bq query --use_legacy_sql=false --dry_run \
  'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.test_ads_report`'
```

**スキャン量の違いを `exercises.md` に記録してください**

### 演習2: IAM権限の確認

```bash
# 1. データセットの権限を確認
bq show --format=prettyjson YOUR_PROJECT_ID:DATASET_NAME | grep -A 20 "access"

# 2. サービスアカウント一覧を確認
gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# 3. 自分のアカウントのロールを確認
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:user:YOUR_EMAIL"
```

## 📝 演習課題

### 課題1: パーティション・クラスタリング設定の理解

学習ロードマップの「raw_marketing_ads_platform_a.daily_report」のテーブル定義（206-244行目）を読み、以下を説明してください：

1. なぜ`date`カラムでパーティショニングしているのか？
2. なぜ`account_id, campaign_id`でクラスタリングしているのか？
3. `partition_expiration_days = 90`の意図は？

**回答を `exercises.md` に記録してください**

### 課題2: 自分のパーティション分割テーブル作成

1. 学習用データセットを作成
2. 30日後に自動削除されるパーティション分割テーブルを作成
3. サンプルデータを複数日分挿入
4. パーティションフィルタの有無でクエリを実行し、スキャン量を比較

### 課題3: スキャン量の比較実験

以下の3つのクエリで`--dry_run`を実行し、スキャン量を比較：

1. パーティションフィルタあり + クラスタリングキーあり
2. パーティションフィルタのみ
3. フィルタなし

## ✅ 完了チェックリスト

- [ ] パーティション分割の概念理解
- [ ] クラスター化の概念理解
- [ ] パーティション分割テーブル作成成功
- [ ] `--dry_run`でスキャン量確認
- [ ] パーティションフィルタの効果を実測
- [ ] IAM権限の確認方法理解
- [ ] 演習課題1完了
- [ ] 演習課題2完了
- [ ] 演習課題3完了

## 🔗 次のステップ

完了したら、[Phase 0-03: データモデリングの基礎](../03-data-modeling/README.md)に進んでください。

## 📌 パーティション分割のベストプラクティス

1. **必ずパーティションフィルタを使用**
   - `WHERE date >= '2025-01-01'`のように日付範囲を指定

2. **保持期間の設定**
   - 不要な古いデータは自動削除してコスト削減

3. **クラスタリングとの組み合わせ**
   - パーティション: 日付
   - クラスタリング: よく検索するカラム（ID、カテゴリなど）

4. **外部テーブルの使い方**
   - 頻繁にクエリしないデータはGCSに保存
   - 必要な時だけ外部テーブルでクエリ

## ❓ トラブルシューティング

### パーティション分割テーブルが作成できない

```bash
# エラー内容を確認
bq show --format=prettyjson PROJECT:DATASET.TABLE
```

### スキャン量が予想より多い

- パーティションフィルタを使用しているか確認
- `WHERE date BETWEEN X AND Y`形式を使用
- `CURRENT_DATE()`などの関数を活用

### 権限エラー

- `bigquery.dataEditor`または`bigquery.admin`が必要
- プロジェクトオーナーに権限付与を依頼
