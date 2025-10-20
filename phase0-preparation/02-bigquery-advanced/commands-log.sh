#!/bin/bash
# Phase 0-02: BigQuery高度な機能 実行コマンドログ

# ============================================
# パーティション分割テーブルの作成
# ============================================

# データセット作成
# bq mk --dataset --location=asia-northeast1 YOUR_PROJECT_ID:learning_dev

# thelook_ecommerceのeventsデータからパーティション分割テーブルを作成
# bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.events_partitioned \
#   --time_partitioning_field=event_date \
#   --time_partitioning_type=DAY \
#   --time_partitioning_expiration=7776000 \
#   --clustering_fields=traffic_source,event_type \
#   'SELECT
#     id,
#     user_id,
#     session_id,
#     created_at,
#     DATE(created_at) as event_date,
#     event_type,
#     traffic_source,
#     browser,
#     city,
#     state
#    FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE created_at >= "2024-01-01"
#      AND created_at < "2024-02-01"
#    LIMIT 100000'

# ordersテーブルもパーティション分割
# bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.orders_partitioned \
#   --time_partitioning_field=order_date \
#   --time_partitioning_type=DAY \
#   --clustering_fields=status,user_id \
#   'SELECT
#     order_id,
#     user_id,
#     status,
#     gender,
#     created_at,
#     DATE(created_at) as order_date,
#     shipped_at,
#     delivered_at,
#     num_of_item
#    FROM `bigquery-public-data.thelook_ecommerce.orders`
#    WHERE created_at >= "2024-01-01"
#      AND created_at < "2024-02-01"'


# ============================================
# スキャン量の確認（パーティション効果の実証）
# ============================================

# パーティションフィルタあり（ドライラン）
# bq query --use_legacy_sql=false --dry_run \
#   'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
#    WHERE event_date = "2024-01-01"'

# パーティションフィルタなし（ドライラン）
# bq query --use_legacy_sql=false --dry_run \
#   'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
#    WHERE event_type = "purchase"'

# クラスタリング効果の確認（traffic_sourceでフィルタ）
# bq query --use_legacy_sql=false --dry_run \
#   'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
#    WHERE event_date = "2024-01-01"
#      AND traffic_source = "Email"'

# パーティション+クラスタリングの両方を活用
# bq query --use_legacy_sql=false --dry_run \
#   'SELECT
#     traffic_source,
#     event_type,
#     COUNT(*) as event_count
#    FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
#    WHERE event_date BETWEEN "2024-01-01" AND "2024-01-07"
#      AND traffic_source IN ("Email", "Adwords")
#    GROUP BY traffic_source, event_type'


# ============================================
# 外部テーブルの作成（応用編）
# ============================================

# GCSにエクスポートしてから外部テーブルとして読み込む例
# 1. BigQueryからGCSへエクスポート
# bq extract --destination_format=PARQUET \
#   YOUR_PROJECT_ID:learning_dev.events_partitioned \
#   gs://YOUR_BUCKET/thelook_events/*.parquet

# 2. 外部テーブルとして定義
# bq mk --external_table_definition=@PARQUET=gs://YOUR_BUCKET/thelook_events/*.parquet \
#   YOUR_PROJECT_ID:learning_dev.events_external


# ============================================
# IAM権限の確認
# ============================================

# データセットの権限確認
# bq show --format=prettyjson YOUR_PROJECT_ID:learning_dev | grep -A 20 "access"

# 公開データセットの権限確認（参考）
# bq show --format=prettyjson bigquery-public-data:thelook_ecommerce | grep -A 20 "access"

# サービスアカウント一覧
# gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# 自分のロール確認
# gcloud projects get-iam-policy YOUR_PROJECT_ID \
#   --flatten="bindings[].members" \
#   --format="table(bindings.role)" \
#   --filter="bindings.members:user:YOUR_EMAIL"


# ============================================
# パーティション情報の確認
# ============================================

# パーティション一覧の確認
# bq query --use_legacy_sql=false \
#   'SELECT
#     partition_id,
#     total_rows,
#     total_logical_bytes
#    FROM `YOUR_PROJECT_ID.learning_dev.INFORMATION_SCHEMA.PARTITIONS`
#    WHERE table_name = "events_partitioned"
#    ORDER BY partition_id DESC
#    LIMIT 10'


# ============================================
# クリーンアップ
# ============================================

# テーブルのみ削除
# bq rm -f YOUR_PROJECT_ID:learning_dev.events_partitioned
# bq rm -f YOUR_PROJECT_ID:learning_dev.orders_partitioned

# データセットごと削除
# bq rm -r -f YOUR_PROJECT_ID:learning_dev
