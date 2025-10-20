#!/bin/bash
# Phase 0-04: サービスアカウントとIAM設計 実行コマンドログ

# ============================================
# サービスアカウントの作成
# ============================================

# サービスアカウント作成
# gcloud iam service-accounts create learning-test-sa \
#   --display-name="学習用テストサービスアカウント" \
#   --project=YOUR_PROJECT_ID

# サービスアカウント一覧確認
# gcloud iam service-accounts list --project=YOUR_PROJECT_ID

# サービスアカウント詳細確認
# gcloud iam service-accounts describe SA_EMAIL


# ============================================
# 権限の付与
# ============================================

# データセットへの閲覧権限付与
# bq add-iam-policy-binding \
#   --member=serviceAccount:SA_EMAIL \
#   --role=roles/bigquery.dataViewer \
#   PROJECT_ID:DATASET_NAME

# データセットへの編集権限付与
# bq add-iam-policy-binding \
#   --member=serviceAccount:SA_EMAIL \
#   --role=roles/bigquery.dataEditor \
#   PROJECT_ID:DATASET_NAME


# ============================================
# 権限の確認
# ============================================

# データセットの権限確認
# bq show --format=prettyjson PROJECT_ID:DATASET_NAME | grep -A 10 "access"

# 特定のサービスアカウントの権限確認
# bq show --format=prettyjson PROJECT_ID:DATASET_NAME | grep -A 5 "SA_NAME"


# ============================================
# 権限の削除
# ============================================

# 権限の削除
# bq remove-iam-policy-binding \
#   --member=serviceAccount:SA_EMAIL \
#   --role=roles/bigquery.dataViewer \
#   PROJECT_ID:DATASET_NAME


# ============================================
# サービスアカウントの削除
# ============================================

# サービスアカウント削除
# gcloud iam service-accounts delete SA_EMAIL --project=YOUR_PROJECT_ID


# ============================================
# 自分のアカウントの権限確認
# ============================================

# 自分のロール確認
# gcloud projects get-iam-policy YOUR_PROJECT_ID \
#   --flatten="bindings[].members" \
#   --filter="bindings.members:user:YOUR_EMAIL"
