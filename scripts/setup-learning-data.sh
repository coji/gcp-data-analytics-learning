#!/bin/bash
# 学習用データセットのセットアップスクリプト
# thelook_ecommerce公開データセットから学習用データをコピー

set -e  # エラーが発生したら即座に終了

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 GCP データ分析基盤 学習環境セットアップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
echo "  Project: $PROJECT_ID"
echo ""

# プロジェクトIDの確認
if [ -z "$PROJECT_ID" ]; then
  echo "❌ GCPプロジェクトが設定されていません"
  echo ""
  echo "以下のコマンドでプロジェクトを設定してください："
  echo "  gcloud config set project YOUR_PROJECT_ID"
  echo ""
  echo "または、学習用configurationを作成してください："
  echo "  gcloud config configurations create learning-gcp"
  echo "  gcloud config configurations activate learning-gcp"
  echo "  gcloud config set project YOUR_PROJECT_ID"
  echo ""
  echo "詳細: multi-account-setup.md を参照"
  exit 1
fi

# 警告: 本番環境でないことを確認
if [[ "$PROJECT_ID" == *"prod"* ]] || [[ "$PROJECT_ID" == *"production"* ]]; then
  echo "⚠️  警告: プロジェクトIDに 'prod' または 'production' が含まれています"
  echo "   このスクリプトは学習用です。本番環境では実行しないでください。"
  echo ""
  read -p "本当に続行しますか？ (yes/NO): " -r
  if [[ ! $REPLY == "yes" ]]; then
    echo "中止しました"
    exit 0
  fi
fi

echo "✅ プロジェクト確認完了"
echo ""

# データセット名
DATASET="learning_dev"
LOCATION="asia-northeast1"

# データ期間の設定
START_DATE="2024-01-01"
END_DATE="2024-02-01"
LIMIT_EVENTS=100000  # eventsテーブルは大きいので制限

echo "📦 セットアップ内容:"
echo "  - データセット: $DATASET"
echo "  - ロケーション: $LOCATION"
echo "  - データ期間: $START_DATE 〜 $END_DATE"
echo "  - eventsテーブル制限: $LIMIT_EVENTS 件"
echo ""

read -p "続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "中止しました"
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 データセット作成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# データセット作成
bq mk --dataset \
  --location=$LOCATION \
  --description="学習用テストデータセット（thelook_ecommerceからコピー）" \
  $PROJECT_ID:$DATASET 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ データセット作成完了: $DATASET"
else
  echo "ℹ️  データセット $DATASET は既に存在します"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（1/6: events）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# eventsテーブル
echo "コピー中: events（制限: $LIMIT_EVENTS 件）..."
bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:$DATASET.events --replace \
  "SELECT * FROM \`bigquery-public-data.thelook_ecommerce.events\`
   WHERE created_at >= '$START_DATE'
     AND created_at < '$END_DATE'
   LIMIT $LIMIT_EVENTS"

echo "✅ eventsテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（2/6: orders）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ordersテーブル
echo "コピー中: orders..."
bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:$DATASET.orders --replace \
  "SELECT * FROM \`bigquery-public-data.thelook_ecommerce.orders\`
   WHERE created_at >= '$START_DATE'
     AND created_at < '$END_DATE'"

echo "✅ ordersテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（3/6: order_items）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# order_itemsテーブル
echo "コピー中: order_items..."
bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:$DATASET.order_items --replace \
  "SELECT * FROM \`bigquery-public-data.thelook_ecommerce.order_items\`
   WHERE created_at >= '$START_DATE'
     AND created_at < '$END_DATE'"

echo "✅ order_itemsテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（4/6: users）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# usersテーブル（マスタなので期間制限なし、ただし必要なユーザーのみ）
echo "コピー中: users（関連ユーザーのみ）..."
bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:$DATASET.users --replace \
  "SELECT DISTINCT u.*
   FROM \`bigquery-public-data.thelook_ecommerce.users\` u
   INNER JOIN \`bigquery-public-data.thelook_ecommerce.orders\` o
     ON u.id = o.user_id
   WHERE o.created_at >= '$START_DATE'
     AND o.created_at < '$END_DATE'"

echo "✅ usersテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（5/6: products）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# productsテーブル（マスタなので期間制限なし、ただし必要な商品のみ）
echo "コピー中: products（関連商品のみ）..."
bq query --use_legacy_sql=false --destination_table=$PROJECT_ID:$DATASET.products --replace \
  "SELECT DISTINCT p.*
   FROM \`bigquery-public-data.thelook_ecommerce.products\` p
   INNER JOIN \`bigquery-public-data.thelook_ecommerce.order_items\` oi
     ON p.id = oi.product_id
   WHERE oi.created_at >= '$START_DATE'
     AND oi.created_at < '$END_DATE'"

echo "✅ productsテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 テーブル作成（6/6: events_partitioned - パーティション分割版）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# パーティション分割されたeventsテーブル
echo "コピー中: events_partitioned（パーティション+クラスタリング）..."
bq query --use_legacy_sql=false \
  --destination_table=$PROJECT_ID:$DATASET.events_partitioned \
  --time_partitioning_field=event_date \
  --time_partitioning_type=DAY \
  --clustering_fields=traffic_source,event_type \
  --replace \
  "SELECT
     id,
     user_id,
     session_id,
     created_at,
     DATE(created_at) as event_date,
     event_type,
     traffic_source,
     browser,
     city,
     state,
     postal_code,
     country,
     uri
   FROM \`bigquery-public-data.thelook_ecommerce.events\`
   WHERE created_at >= '$START_DATE'
     AND created_at < '$END_DATE'
   LIMIT $LIMIT_EVENTS"

echo "✅ events_partitionedテーブル作成完了"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 セットアップ確認"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# テーブル一覧とレコード数を表示
echo "作成されたテーブル:"
bq ls --format=pretty $PROJECT_ID:$DATASET

echo ""
echo "各テーブルのレコード数:"
for table in events orders order_items users products events_partitioned; do
  count=$(bq query --use_legacy_sql=false --format=csv \
    "SELECT COUNT(*) FROM \`$PROJECT_ID.$DATASET.$table\`" | tail -n 1)
  printf "  %-20s: %'10d 件\n" $table $count
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ セットアップ完了！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 次のステップ:"
echo ""
echo "1. データを確認:"
echo "   bq query --use_legacy_sql=false 'SELECT * FROM \`$PROJECT_ID.$DATASET.events\` LIMIT 10'"
echo ""
echo "2. Phase 0-01から学習を開始:"
echo "   cd phase0-preparation/01-gcp-cli"
echo "   cat README.md"
echo ""
echo "3. パーティション効果を確認:"
echo "   bq query --use_legacy_sql=false --dry_run \\"
echo "     'SELECT * FROM \`$PROJECT_ID.$DATASET.events_partitioned\` WHERE event_date = \"$START_DATE\"'"
echo ""
echo "Happy Learning! 🚀"
