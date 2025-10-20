#!/bin/bash
# Phase 0-01: GCP CLI 実行コマンドログ
# 学習中に実行したコマンドを記録するファイル

# ============================================
# 認証とプロジェクト設定
# ============================================

# 認証
# gcloud auth login

# プロジェクト設定
# gcloud config set project YOUR_PROJECT_ID

# 現在の設定確認
# gcloud config list


# ============================================
# BigQuery公開データセットの確認
# ============================================

# thelook_ecommerce データセットの詳細確認
# bq show --format=prettyjson bigquery-public-data:thelook_ecommerce

# テーブル一覧
# bq ls bigquery-public-data:thelook_ecommerce

# eventsテーブルのスキーマ確認
# bq show --schema --format=prettyjson bigquery-public-data:thelook_ecommerce.events

# ordersテーブルのスキーマ確認
# bq show --schema --format=prettyjson bigquery-public-data:thelook_ecommerce.orders


# ============================================
# クエリの実行（thelook_ecommerce使用）
# ============================================

# シンプルなクエリ
# bq query --use_legacy_sql=false 'SELECT CURRENT_DATE() as today, "Hello BigQuery" as message'

# 流入元別のセッション数（集計クエリ）
# bq query --use_legacy_sql=false \
#   'SELECT
#     traffic_source,
#     COUNT(DISTINCT session_id) as sessions
#    FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE DATE(created_at) = "2024-01-01"
#    GROUP BY traffic_source
#    ORDER BY sessions DESC'

# 過去7日間の日別注文数
# bq query --use_legacy_sql=false \
#   'SELECT
#     DATE(created_at) as order_date,
#     COUNT(*) as order_count,
#     SUM(num_of_item) as total_items
#    FROM `bigquery-public-data.thelook_ecommerce.orders`
#    WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
#    GROUP BY order_date
#    ORDER BY order_date DESC'

# ドライラン（スキャン量確認）
# bq query --use_legacy_sql=false --dry_run \
#   'SELECT * FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE DATE(created_at) = "2024-01-01"'


# ============================================
# 学習用データセット作成
# ============================================

# データセット作成
# bq mk --dataset --location=asia-northeast1 --description="学習用テストデータセット" YOUR_PROJECT_ID:learning_dev

# サンプルデータをコピー（eventsテーブル - 2024年1月の10万件）
# bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.events \
#   'SELECT * FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE created_at >= "2024-01-01"
#      AND created_at < "2024-02-01"
#    LIMIT 100000'

# サンプルデータをコピー（ordersテーブル - 2024年1月）
# bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.orders \
#   'SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`
#    WHERE created_at >= "2024-01-01"
#      AND created_at < "2024-02-01"'

# サンプルデータをコピー（order_itemsテーブル - 2024年1月）
# bq query --use_legacy_sql=false --destination_table=YOUR_PROJECT_ID:learning_dev.order_items \
#   'SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items`
#    WHERE created_at >= "2024-01-01"
#      AND created_at < "2024-02-01"'

# コピーしたデータの確認
# bq query --use_legacy_sql=false \
#   'SELECT COUNT(*) as record_count FROM `YOUR_PROJECT_ID.learning_dev.events`'


# ============================================
# クリーンアップ
# ============================================

# データセット削除
# bq rm -r -f YOUR_PROJECT_ID:learning_dev


# ============================================
# 演習課題用コマンド
# ============================================

# 課題1: 流入元別のイベントタイプ分析
# bq query --use_legacy_sql=false \
#   'SELECT
#     traffic_source,
#     event_type,
#     COUNT(*) as event_count
#    FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE DATE(created_at) = "2024-01-01"
#    GROUP BY traffic_source, event_type
#    ORDER BY traffic_source, event_count DESC'

# 課題2: 上位10件のアクティブユーザー
# bq query --use_legacy_sql=false \
#   'SELECT
#     user_id,
#     COUNT(*) as event_count,
#     COUNT(DISTINCT session_id) as session_count
#    FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE DATE(created_at) = "2024-01-01"
#      AND user_id IS NOT NULL
#    GROUP BY user_id
#    ORDER BY event_count DESC
#    LIMIT 10'

# 課題3: 購入完了率（purchase / sessions）
# bq query --use_legacy_sql=false \
#   'SELECT
#     COUNT(DISTINCT session_id) as total_sessions,
#     COUNT(DISTINCT CASE WHEN event_type = "purchase" THEN session_id END) as purchase_sessions,
#     ROUND(SAFE_DIVIDE(
#       COUNT(DISTINCT CASE WHEN event_type = "purchase" THEN session_id END),
#       COUNT(DISTINCT session_id)
#     ) * 100, 2) as purchase_rate_percent
#    FROM `bigquery-public-data.thelook_ecommerce.events`
#    WHERE DATE(created_at) = "2024-01-01"'
