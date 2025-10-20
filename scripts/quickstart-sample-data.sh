#!/bin/bash
# クイックスタート: サンプルデータで学習を始める

echo "🚀 GCP データ分析基盤 学習 - クイックスタート"
echo ""

# 現在のgcloud設定を確認
CURRENT_CONFIG=$(gcloud config configurations list --filter="is_active:true" --format="value(name)" 2>/dev/null)
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

echo "📋 現在のgcloud設定:"
if [ -n "$CURRENT_CONFIG" ]; then
  echo "  Configuration: $CURRENT_CONFIG"
fi
echo "  Account: $CURRENT_ACCOUNT"
echo "  Project: ${PROJECT_ID:-（未設定）}"
echo ""

if [ -z "$PROJECT_ID" ]; then
  echo "ℹ️  プロジェクトが設定されていませんが、公開データセットのクエリは実行できます"
  echo ""
fi

# 学習用データセットの作成
echo "📦 学習用データセット (learning_dev) を作成します..."
bq mk --dataset --location=asia-northeast1 --description="学習用テストデータセット" $PROJECT_ID:learning_dev 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ データセット作成完了"
else
  echo "ℹ️  データセットは既に存在します"
fi
echo ""

# サンプルクエリ1: 流入元別のセッション数
echo "📊 サンプルクエリ1: 流入元別のセッション数（2024-01-01）"
echo ""
bq query --use_legacy_sql=false --max_rows=10 '
SELECT
  traffic_source,
  COUNT(DISTINCT session_id) as sessions,
  COUNT(CASE WHEN event_type = "purchase" THEN 1 END) as purchases
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE DATE(created_at) = "2024-01-01"
GROUP BY traffic_source
ORDER BY sessions DESC
'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# サンプルクエリ2: イベントタイプ別の集計
echo "📊 サンプルクエリ2: イベントタイプ別の集計"
echo ""
bq query --use_legacy_sql=false --max_rows=10 '
SELECT
  event_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE DATE(created_at) = "2024-01-01"
GROUP BY event_type
ORDER BY event_count DESC
'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 次のステップ
echo "🎓 次のステップ"
echo ""
echo "1. 詳細なサンプルデータガイドを確認:"
echo "   cat sample-data-guide.md"
echo ""
echo "2. Phase 0-01から学習を開始:"
echo "   cd phase0-preparation/01-gcp-cli"
echo "   cat README.md"
echo ""
echo "3. サンプルデータを自分のデータセットにコピー:"
echo "   bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:learning_dev.events \\"
echo "     'SELECT * FROM \`bigquery-public-data.thelook_ecommerce.events\`"
echo "      WHERE created_at >= \"2024-01-01\" LIMIT 100000'"
echo ""
echo "Happy Learning! 🚀"
