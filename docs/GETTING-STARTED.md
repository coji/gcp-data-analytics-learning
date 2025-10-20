# はじめに - Getting Started

このガイドでは、GCPデータ分析基盤の学習を最速で開始する方法を説明します。

## 🚀 5分でスタート

### 0. ⚠️ 重要: Claude Code 学習モードの設定

**このリポジトリは Claude Code の学習モード (`/output-style learning`) で使用することを前提に設計されています。**

最初に学習モードを設定してください：

```
/output-style learning
```

学習モードでは：
- 詳細な概念説明
- 段階的な学習サポート
- ハンズオン演習の丁寧なガイド
- エラー時の教育的な解説

**詳細は [learning-mode-guide.md](learning-mode-guide.md) を参照してください。**

### 1. 前提条件の確認

```bash
# gcloud CLIがインストールされているか確認
gcloud --version

# BigQueryコマンドが使えるか確認
bq --version
```

インストールされていない場合：
```bash
# macOS
brew install --cask google-cloud-sdk

# その他のOSは公式ドキュメント参照
# https://cloud.google.com/sdk/docs/install
```

### 2. GCP設定（複数アカウント使用時）

**複数のGCPアカウント・プロジェクトを使い分けている方は、学習用の設定を作成することを推奨します。**

```bash
# 学習用configurationを作成
gcloud config configurations create learning-gcp

# アクティブ化
gcloud config configurations activate learning-gcp

# 認証（学習用アカウントでログイン）
gcloud auth login

# 学習用プロジェクトを設定
gcloud config set project YOUR_LEARNING_PROJECT_ID

# 確認
gcloud config list
```

**詳細は [multi-account-setup.md](multi-account-setup.md) を参照してください。**

#### シンプルな設定（1つのアカウントのみ使用）

```bash
# 認証
gcloud auth login

# プロジェクトを設定
gcloud config set project YOUR_PROJECT_ID

# 確認
gcloud config list
```

### 3. サンプルデータで動作確認

```bash
# 学習用設定に切り替え（複数アカウント使用時）
../scripts/switch-to-learning.sh

# クイックスタートスクリプト実行
../scripts/quickstart-sample-data.sh
```

このスクリプトは：
- BigQuery公開データセット（`thelook_ecommerce`）にクエリ実行
- 流入元別のセッション数を集計
- イベントタイプ別の集計を実行

### 4. 学習用データセットのセットアップ

```bash
# 自分のプロジェクトに学習用データをコピー
../scripts/setup-learning-data.sh
```

このスクリプトは：
- `learning_dev` データセットを作成
- 2024年1月のデータをコピー（events, orders, order_items, users, products）
- パーティション分割版のテーブルも作成

**所要時間**: 約3-5分

## 📚 学習の進め方

### 学習モードでの Claude Code の活用

学習を開始する際は、Claude に以下のように伝えてください：

```
Phase 0-01 から学習を開始したいです。
基礎から丁寧に説明してください。
```

Claude は：
- 各概念を段階的に説明
- ハンズオン演習を丁寧にガイド
- コマンドの意味と背景を解説
- エラー時に教育的なサポートを提供

**詳細は [learning-mode-guide.md](learning-mode-guide.md) を参照してください。**

### Phase 0: 準備・検証（Week 1-2）

```bash
cd phase0-preparation/01-gcp-cli
cat README.md
```

各ディレクトリには以下が含まれています：
- **README.md**: 学習ガイドとハンズオン演習
- **exercises.md**: 演習メモ用テンプレート
- **commands-log.sh**: 実行コマンド集

**Claude Code に質問しながら進めることを推奨します：**
- 「このコマンドの各オプションの意味を教えてください」
- 「パーティショニングの概念を詳しく説明してください」
- 「今学んだ内容を復習したいです」

### 実際のデータで練習

全ての演習は `thelook_ecommerce` データセットで動作します：

```bash
# Phase 0-01: GCP CLIの基本
cd phase0-preparation/01-gcp-cli
# commands-log.sh のコマンドを実行

# Phase 0-02: BigQuery高度な機能
cd ../02-bigquery-advanced
# パーティション分割の効果を確認

# Phase 1-06: dbt
cd ../../phase1-integration/06-dbt
# dbtモデルのサンプルを実行

# Phase 2-09: 高度なSQL
cd ../../phase2-analytics/09-advanced-sql
# LTV計算やコホート分析のSQLを実行
```

## 📊 利用可能なデータ

### BigQuery公開データセット（無料で使用可能）

**データセット**: `bigquery-public-data.thelook_ecommerce`

| テーブル | 説明 | 主な用途 |
|---------|------|---------|
| events | ユーザー行動（product, cart, purchase等） | 流入元分析、CVR計算 |
| orders | 注文データ | LTV計算、コホート分析 |
| order_items | 注文明細 | 売上分析 |
| users | ユーザーマスタ | ユーザー属性分析 |
| products | 商品マスタ | 商品分析 |

### 学習用データセット（自分のプロジェクトにコピー）

**データセット**: `YOUR_PROJECT_ID.learning_dev`

セットアップ後に以下が利用可能：
- `events` - イベントデータ（2024年1月、10万件）
- `orders` - 注文データ（2024年1月）
- `order_items` - 注文明細（2024年1月）
- `users` - 関連ユーザー
- `products` - 関連商品
- `events_partitioned` - パーティション分割版（Phase 0-02で使用）

## 🎯 学習の流れ

### 1日目: 環境構築とデータ確認

**Claude に質問しながら進めましょう：**

```
学習環境をセットアップしたいです。
setup-learning-data.sh を実行する前に、
このスクリプトが何をするのか説明してください。
```

```bash
# セットアップ
../scripts/setup-learning-data.sh

# データ確認
bq query --use_legacy_sql=false \
  'SELECT
    traffic_source,
    COUNT(DISTINCT session_id) as sessions
   FROM `YOUR_PROJECT_ID.learning_dev.events`
   WHERE DATE(created_at) = "2024-01-01"
   GROUP BY traffic_source'
```

**結果を確認したら Claude に質問：**
```
このクエリの結果から何が分かりますか？
traffic_source ごとのセッション数の違いから、
どんな考察ができますか？
```

### 2-3日目: Phase 0-01, 02（GCP CLI, BigQuery基礎）

**Claude に学習開始を伝える：**
```
Phase 0-01 から学習を開始します。
GCP CLI の基本から教えてください。
```

```bash
cd phase0-preparation/01-gcp-cli
# README.mdに従って演習
# commands-log.sh のコメントを外して実行
# exercises.md に結果を記録
```

**各コマンドの意味を Claude に質問しながら実行してください：**
```
bq query コマンドの --dry_run オプションについて教えてください。
なぜコスト確認が重要なのですか？
```

### 4-5日目: Phase 0-03, 04, 05（モデリング、IAM、Terraform）

概念理解中心のフェーズ。実際のコードは少なめ。

**Claude に概念の説明を求める：**
```
3層アーキテクチャ（Raw/Staging/Mart）について、
なぜこの3層に分けるのか、それぞれの役割とともに説明してください。
```

### Week 2以降: Phase 1（dbt）

**Claude に dbt の概念を質問：**
```
dbt とは何ですか？なぜデータ変換に使うのですか？
従来のETLとの違いを教えてください。
```

```bash
cd phase1-integration/06-dbt
# dbt Fundamentalsコース受講
# サンプルモデルを実行
```

**dbt モデル実行時も Claude に質問：**
```
この dbt モデルで ref() 関数を使っていますが、
これはどういう意味ですか？依存関係の管理とどう関係しますか？
```

### Week 3以降: Phase 2（高度なSQL）

**Claude に SQL の解説を求める：**
```
このLTV計算のSQLを見ています。
各CTEの役割と、WINDOW関数の使い方を説明してください。
```

```bash
cd phase2-analytics/09-advanced-sql
# LTV計算、コホート分析を実践
```

## 📝 学習記録の管理

### 日次ログ

**Claude に学習ログの作成を依頼：**
```
今日の学習内容をまとめたいです。
learning-log/ に今日の日付でログを作成してください。
学んだ概念のサマリーと重要なポイントを含めてください。
```

```bash
# 今日の学習ログを作成
cp learning-log/2025-10-20.md learning-log/$(date +%Y-%m-%d).md
vim learning-log/$(date +%Y-%m-%d).md
```

### 進捗チェックリスト

**Claude に進捗の更新を依頼：**
```
今日完了した Phase 0-01 と Phase 0-02 を
learning-progress.md でチェック済みにしてください。
```

```bash
# 進捗を更新
vim learning-progress.md
# 完了した項目を ✅ に変更
```

## 🔗 便利なリンク

- **[learning-mode-guide.md](learning-mode-guide.md)** - Claude Code 学習モードの使い方（重要）
- [sample-data-guide.md](sample-data-guide.md) - データセット詳細ガイド
- [learning-progress.md](../learning-progress.md) - 進捗チェックリスト
- [CLAUDE.md](CLAUDE.md) - Claude Code用ガイド
- [multi-account-setup.md](multi-account-setup.md) - 複数GCPアカウントの切り替え方法

## ❓ よくある質問

### Q: コストはどのくらいかかりますか？

- BigQuery公開データセット: クエリのスキャン量のみ課金
- `learning_dev`にコピーしたデータ: ストレージ課金（2024年1月分で数MB程度）
- 月5GB程度の学習なら、ほぼ無料枠内

### Q: エラーが出ました

```bash
# 認証エラー
gcloud auth login
gcloud auth application-default login

# プロジェクトが設定されていない
gcloud config set project YOUR_PROJECT_ID

# 権限エラー
# プロジェクトオーナーまたはBigQueryユーザーの権限が必要
```

### Q: データセットを削除したい

```bash
# 学習用データセットを削除
bq rm -r -f YOUR_PROJECT_ID:learning_dev

# 再セットアップ
../scripts/setup-learning-data.sh
```

## 🎓 次のステップ

1. ✅ 環境構築完了
2. → [Phase 0-01: GCP CLI](phase0-preparation/01-gcp-cli/README.md)
3. → [sample-data-guide.md](sample-data-guide.md)で詳細な使い方を確認

---

**Happy Learning! 🚀**
