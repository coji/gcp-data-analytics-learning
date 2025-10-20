#!/bin/bash
# 学習用gcloud設定に切り替えるヘルパースクリプト

echo "🔄 学習用gcloud設定に切り替え"
echo ""

# 学習用configurationが存在するか確認
if ! gcloud config configurations list --format="value(name)" | grep -q "^learning-gcp$"; then
  echo "⚠️  'learning-gcp' configuration が見つかりません"
  echo ""
  echo "以下のコマンドで作成しますか？"
  echo ""
  read -p "作成する場合は y を入力: " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "学習用configurationを作成します..."
    gcloud config configurations create learning-gcp

    echo ""
    read -p "学習用のGoogleアカウント（例: your-email@gmail.com）: " ACCOUNT
    read -p "学習用のGCPプロジェクトID: " PROJECT

    gcloud config configurations activate learning-gcp
    gcloud config set account "$ACCOUNT"
    gcloud config set project "$PROJECT"
    gcloud config set compute/region asia-northeast1

    echo ""
    echo "✅ 学習用configuration作成完了"
    echo ""
    echo "次のステップ: 認証を実行してください"
    echo "  gcloud auth login"
    echo "  gcloud auth application-default login"
  else
    echo "中止しました"
    exit 0
  fi
else
  # 既存のconfigurationに切り替え
  gcloud config configurations activate learning-gcp
  echo "✅ 'learning-gcp' configuration に切り替えました"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 現在の設定"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
gcloud config list

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 次のステップ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. 認証状態を確認:"
echo "   gcloud auth list"
echo ""
echo "2. 未認証の場合は認証を実行:"
echo "   gcloud auth login"
echo ""
echo "3. BigQueryの接続テスト:"
echo "   bq ls"
echo ""
echo "4. セットアップスクリプト実行:"
echo "   ./setup-learning-data.sh"
echo ""
