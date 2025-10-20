# 学習用サンプルデータガイド

## 📦 使用するオープンデータ

### BigQuery公開データセット: `thelook_ecommerce`

Eコマースサイトの実データに近いサンプルデータセット。広告分析・マーケティング分析の学習に最適。

**プロジェクトID**: `bigquery-public-data`
**データセット**: `thelook_ecommerce`

## 🗂️ テーブル構成

### 1. events（ユーザー行動データ）

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.events` LIMIT 5;
```

| カラム | 型 | 説明 |
|--------|----|----|
| id | INTEGER | イベントID |
| user_id | INTEGER | ユーザーID |
| session_id | STRING | セッションID |
| created_at | TIMESTAMP | イベント発生日時 |
| event_type | STRING | イベント種別（product, cart, purchase, cancel等） |
| traffic_source | STRING | 流入元（Email, Adwords, YouTube, Facebook等） |
| ip_address | STRING | IPアドレス |
| city, state | STRING | 地域情報 |

**用途**: Raw Layerのデータソースとして最適

### 2. orders（注文データ）

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders` LIMIT 5;
```

| カラム | 型 | 説明 |
|--------|----|----|
| order_id | INTEGER | 注文ID |
| user_id | INTEGER | ユーザーID |
| status | STRING | 注文ステータス（Complete, Cancelled等） |
| created_at | TIMESTAMP | 注文日時 |
| delivered_at | TIMESTAMP | 配送完了日時 |

**用途**: LTV計算、コホート分析

### 3. order_items（注文明細）

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` LIMIT 5;
```

| カラム | 型 | 説明 |
|--------|----|----|
| id | INTEGER | 明細ID |
| order_id | INTEGER | 注文ID |
| user_id | INTEGER | ユーザーID |
| product_id | INTEGER | 商品ID |
| sale_price | FLOAT | 販売価格 |

**用途**: 売上分析、商品分析

### 4. users（ユーザーマスタ）

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.users` LIMIT 5;
```

| カラム | 型 | 説明 |
|--------|----|----|
| id | INTEGER | ユーザーID |
| first_name, last_name | STRING | 氏名 |
| email | STRING | メールアドレス |
| age | INTEGER | 年齢 |
| gender | STRING | 性別 |
| created_at | TIMESTAMP | 登録日時 |

**用途**: ユーザー分析

### 5. products（商品マスタ）

```sql
SELECT * FROM `bigquery-public-data.thelook_ecommerce.products` LIMIT 5;
```

| カラム | 型 | 説明 |
|--------|----|----|
| id | INTEGER | 商品ID |
| name | STRING | 商品名 |
| category | STRING | カテゴリ |
| cost, retail_price | FLOAT | 原価、小売価格 |

**用途**: 商品分析

## 🎯 学習での活用方法

### Phase 0: 基礎学習

#### 01. GCP CLI演習

```bash
# データセット確認
bq show --format=prettyjson bigquery-public-data:thelook_ecommerce

# テーブル一覧
bq ls bigquery-public-data:thelook_ecommerce

# スキーマ確認
bq show --schema --format=prettyjson bigquery-public-data:thelook_ecommerce.events
```

#### 02. BigQuery高度な機能演習

```sql
-- パーティション分割テーブルの作成（eventsデータをコピー）
CREATE TABLE `YOUR_PROJECT.learning_dev.events_partitioned`
PARTITION BY DATE(created_at)
CLUSTER BY traffic_source, event_type
AS
SELECT * FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE created_at >= '2024-01-01';

-- スキャン量の比較
-- パーティションフィルタあり
SELECT COUNT(*)
FROM `YOUR_PROJECT.learning_dev.events_partitioned`
WHERE DATE(created_at) = '2024-01-01';

-- フィルタなし
SELECT COUNT(*)
FROM `YOUR_PROJECT.learning_dev.events_partitioned`;
```

### Phase 1: データ統合

#### 06. dbt演習

**Staging Layer**: eventsデータの標準化

```sql
-- models/staging/stg_events.sql
{{
  config(
    materialized='view'
  )
}}

SELECT
  id as event_id,
  user_id,
  session_id,
  created_at as event_timestamp,
  DATE(created_at) as event_date,
  event_type,
  traffic_source,
  city,
  state,
  browser
FROM {{ source('thelook', 'events') }}
WHERE created_at >= '2024-01-01'
```

**Mart Layer**: 流入元別の購入分析

```sql
-- models/marts/mart_traffic_source_performance.sql
{{
  config(
    materialized='table'
  )
}}}

WITH events_agg AS (
  SELECT
    DATE(created_at) as date,
    traffic_source,
    COUNT(DISTINCT session_id) as sessions,
    COUNT(CASE WHEN event_type = 'product' THEN 1 END) as product_views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) as add_to_carts,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) as purchases
  FROM {{ ref('stg_events') }}
  GROUP BY date, traffic_source
),

orders_agg AS (
  SELECT
    DATE(o.created_at) as date,
    e.traffic_source,
    SUM(oi.sale_price) as revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  LEFT JOIN `bigquery-public-data.thelook_ecommerce.events` e
    ON o.user_id = e.user_id
    AND e.event_type = 'purchase'
    AND DATE(o.created_at) = DATE(e.created_at)
  WHERE o.status = 'Complete'
  GROUP BY date, traffic_source
)

SELECT
  e.date,
  e.traffic_source,
  e.sessions,
  e.product_views,
  e.add_to_carts,
  e.purchases,
  COALESCE(o.revenue, 0) as revenue,
  SAFE_DIVIDE(e.purchases, e.sessions) as cvr,
  SAFE_DIVIDE(o.revenue, e.sessions) as revenue_per_session
FROM events_agg e
LEFT JOIN orders_agg o
  ON e.date = o.date
  AND e.traffic_source = o.traffic_source
ORDER BY e.date DESC, revenue DESC
```

### Phase 2: 高度な分析

#### 09. LTV計算

```sql
-- 7日・30日・60日LTV計算
WITH user_first_order AS (
  SELECT
    user_id,
    MIN(created_at) as first_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

user_revenue AS (
  SELECT
    o.user_id,
    fo.first_order_date,
    DATE(o.created_at) as order_date,
    SUM(oi.sale_price) as order_revenue,
    DATE_DIFF(DATE(o.created_at), DATE(fo.first_order_date), DAY) as days_since_first
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN user_first_order fo
    ON o.user_id = fo.user_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id, fo.first_order_date, order_date
)

SELECT
  user_id,
  first_order_date,
  -- 7日LTV
  SUM(CASE WHEN days_since_first <= 7 THEN order_revenue ELSE 0 END) as ltv_7d,
  -- 30日LTV
  SUM(CASE WHEN days_since_first <= 30 THEN order_revenue ELSE 0 END) as ltv_30d,
  -- 60日LTV
  SUM(CASE WHEN days_since_first <= 60 THEN order_revenue ELSE 0 END) as ltv_60d,
  -- 全期間LTV
  SUM(order_revenue) as ltv_total
FROM user_revenue
GROUP BY user_id, first_order_date
ORDER BY ltv_total DESC
LIMIT 100;
```

#### コホート分析

```sql
-- 月次コホートのリテンション率
WITH cohort_base AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), MONTH) as cohort_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

cohort_activity AS (
  SELECT
    cb.cohort_month,
    cb.user_id,
    DATE_TRUNC(o.created_at, MONTH) as activity_month,
    DATE_DIFF(DATE_TRUNC(o.created_at, MONTH), cb.cohort_month, MONTH) as months_since_cohort
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  WHERE o.status = 'Complete'
)

SELECT
  cohort_month,
  months_since_cohort,
  COUNT(DISTINCT user_id) as retained_users
FROM cohort_activity
GROUP BY cohort_month, months_since_cohort
ORDER BY cohort_month, months_since_cohort;
```

## 🚀 クイックスタート

### 1. 開発用データセット作成

```bash
# データセット作成
bq mk --dataset --location=asia-northeast1 YOUR_PROJECT_ID:learning_dev

# サンプルデータをコピー（2024年以降の直近データ）
bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.events \
  'SELECT * FROM `bigquery-public-data.thelook_ecommerce.events`
   WHERE created_at >= "2024-01-01" LIMIT 100000'

bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.orders \
  'SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`
   WHERE created_at >= "2024-01-01"'

bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.order_items \
  'SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items`
   WHERE created_at >= "2024-01-01"'
```

### 2. 基本的な分析クエリ

```sql
-- 流入元別のコンバージョン率
SELECT
  traffic_source,
  COUNT(DISTINCT session_id) as sessions,
  COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) as purchases,
  ROUND(SAFE_DIVIDE(
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END),
    COUNT(DISTINCT session_id)
  ) * 100, 2) as cvr_percent
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE created_at >= '2024-01-01'
GROUP BY traffic_source
ORDER BY purchases DESC;
```

## 📌 注意事項

### コスト管理

- 公開データセットの**クエリはスキャン量に応じて課金**される
- `LIMIT`句を使って小さく始める
- `--dry_run`でスキャン量を事前確認

```bash
# スキャン量確認
bq query --use_legacy_sql=false --dry_run \
  'SELECT * FROM `bigquery-public-data.thelook_ecommerce.events`'
```

### データの特徴

- 実際のEコマースサイトを模したデータ
- 2020年〜2024年のデータが含まれる
- 個人情報は匿名化済み
- 学習・検証目的で自由に利用可能

## 🔗 学習ロードマップとの対応

| フェーズ | 使用テーブル | 学習内容 |
|---------|------------|---------|
| Phase 0-01 | 全テーブル | bqコマンドの練習 |
| Phase 0-02 | events | パーティション・クラスタリング |
| Phase 0-03 | 全テーブル | 3層アーキテクチャ設計 |
| Phase 1-06 | events, orders | dbtモデル作成 |
| Phase 2-09 | orders, order_items | LTV計算、コホート分析 |

## 📚 参考リンク

- [BigQuery公開データセット](https://cloud.google.com/bigquery/public-data)
- [thelook_ecommerce スキーマ詳細](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=thelook_ecommerce&page=dataset)

---

**このデータセットを使って、実践的なデータ分析基盤の学習を始めましょう！** 🚀
