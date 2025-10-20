# GCP データ分析基盤 学習プロジェクト

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Learning%20Mode-blue)](https://claude.ai/claude-code)
[![GCP](https://img.shields.io/badge/Google%20Cloud-BigQuery-4285F4?logo=google-cloud)](https://cloud.google.com/bigquery)

このリポジトリは、Google Cloud Platform (GCP) を使用したデータ分析基盤構築のための学習プロジェクトです。

**BigQueryをユーザーとして使ったことがある方**が、**データエンジニアリングの実践スキル**を習得することを目指します。

## ✨ 特徴

- 📚 **段階的な学習パス** - Phase 0から2まで体系的に学習
- 🎯 **実践的なハンズオン** - BigQuery公開データセット（thelook_ecommerce）を使用
- 🤖 **Claude Code 学習モード対応** - AI支援による効果的な学習
- 🔄 **複数アカウント対応** - クライアントワークとの両立をサポート
- 📝 **進捗管理** - 学習ログとチェックリストで進捗を可視化

## 📚 学習教材

- **[GETTING-STARTED.md](./docs/GETTING-STARTED.md)** - 🚀 **まずはここから！5分で学習開始**
- **[learning-mode-guide.md](./docs/learning-mode-guide.md)** - 🎓 **Claude Code 学習モードの使い方（重要）**
- **[multi-account-setup.md](./docs/multi-account-setup.md)** - 🔄 **複数GCPアカウントの切り替え方法**
- **[sample-data-guide.md](./docs/sample-data-guide.md)** - 学習用オープンデータの使い方（BigQuery公開データセット）
- **[CLAUDE.md](./docs/CLAUDE.md)** - Claude Code用の技術ガイド
- **[DEVELOPMENT.md](./docs/DEVELOPMENT.md)** - 開発者向けガイド（Markdownlint等）

## 🎯 学習目標

BigQueryをユーザーとして使ったことがある方が、以下のスキルを習得することを目指します：

- BigQueryの高度な機能（パーティショニング、クラスタリング、IAM設計）
- dbt（データ変換のコード管理ツール）
- データモデリング（3層アーキテクチャ：Raw/Staging/Mart）
- Terraform（インフラのコード管理）
- GCP CLIツール（gcloud, bq）の実践的な使い方
- データパイプライン設計

## 📁 ディレクトリ構造

```
gcloud/
├── README.md                   # プロジェクト概要
├── LICENSE                     # MITライセンス
├── CONTRIBUTING.md             # 貢献ガイド
├── learning-progress.md        # 進捗チェックリスト
├── docs/                       # ドキュメント
│   ├── GETTING-STARTED.md      # クイックスタートガイド
│   ├── CLAUDE.md               # Claude Code用ガイド
│   ├── learning-mode-guide.md  # 学習モードガイド
│   ├── multi-account-setup.md  # 複数アカウント管理
│   ├── sample-data-guide.md    # サンプルデータガイド
├── scripts/                    # セットアップスクリプト
│   ├── quickstart-sample-data.sh
│   ├── setup-learning-data.sh
│   └── switch-to-learning.sh
├── config/                     # 設定ファイル例
│   └── .aliases.example
├── learning-log/               # 学習記録（日付ごと）
├── phase0-preparation/         # Phase 0: 準備・検証（2-3週間）
│   ├── 01-gcp-cli/
│   ├── 02-bigquery-advanced/
│   ├── 03-data-modeling/
│   ├── 04-iam-service-accounts/
│   └── 05-terraform/
├── phase1-integration/         # Phase 1: データ統合（1-1.5ヶ月）
│   ├── 06-dbt/
│   ├── 07-appsflyer-pba/
│   └── 08-data-integration/
└── phase2-analytics/           # Phase 2: 分析テンプレート（継続的に）
    ├── 09-advanced-sql/
    ├── 10-bi-tools/
    ├── 11-cloud-scheduler/
    └── 12-monitoring/
```

## 🚀 学習の進め方

### 0. ⚠️ 重要: Claude Code 学習モードの設定

**このリポジトリは Claude Code の学習モード (`/output-style learning`) で使用することを前提に設計されています。**

```
/output-style learning
```

学習モードでは：

- 詳細な概念説明
- 段階的な学習サポート
- ハンズオン演習の丁寧なガイド
- エラー時の教育的な解説

詳細: [learning-mode-guide.md](./learning-mode-guide.md)

### 1. 学習前の準備

1. GCPアカウントの作成（無料トライアルあり）

2. gcloud CLIのインストール

   ```bash
   # macOSの場合
   brew install --cask google-cloud-sdk
   ```

3. **GCP設定**

   **複数アカウント使用時（推奨）**:

   ```bash
   # 学習用configurationを作成
   gcloud config configurations create learning-gcp
   gcloud config configurations activate learning-gcp

   # 認証とプロジェクト設定
   gcloud auth login
   gcloud config set project YOUR_LEARNING_PROJECT_ID
   ```

   詳細: [multi-account-setup.md](./docs/multi-account-setup.md)

   **シンプルな設定**:

   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

4. **クイックスタート（サンプルデータで動作確認）**

   ```bash
   # 学習用設定に切り替え（複数アカウント使用時）
   ./scripts/switch-to-learning.sh

   # サンプルクエリで動作確認
   ./scripts/quickstart-sample-data.sh

   # 学習用データセットをセットアップ（自分のプロジェクトにコピー）
   ./scripts/setup-learning-data.sh
   ```

### 2. 学習プロセス

**Phase 0から順番に学習することを推奨します：**

1. **Claude Code に学習開始を伝える**

   ```
   Phase 0-01 から学習を開始したいです。
   基礎から丁寧に説明してください。
   ```

2. **各フェーズのディレクトリに移動**

   ```bash
   cd phase0-preparation/01-gcp-cli
   ```

3. **README.mdで学習内容を確認**
   - Claude に説明を求める: 「このフェーズで学ぶことを概要から説明してください」

4. **ハンズオン演習を実行**
   - Claude に各コマンドの意味を質問
   - `exercises.md`に演習結果を記録
   - `commands-log.sh`に実行したコマンドを保存

5. **理解を確認**

   ```
   今学んだパーティショニングの概念を、自分の言葉で説明してみます。
   [説明]
   これで合っていますか？
   ```

6. **学習ログを記録**

   ```
   今日の学習内容を learning-log/ にまとめたいです。
   サマリーを作成してください。
   ```

7. **進捗チェックリストを更新**
   - Claude に依頼: 「learning-progress.md を更新してください」

### 3. 推奨学習スケジュール

| 週 | フェーズ | 内容 |
|----|---------|------|
| Week 1-2 | Phase 0 | GCP CLI、BigQuery基礎、IAM設計 |
| Week 3-4 | Phase 0 | dbt集中学習、Terraform基礎 |
| Week 5-6 | Phase 1 | AppsFlyer PBA、データ統合ツール |
| Week 7-8 | Phase 2 | 高度なSQL、ダッシュボード、監視 |

## 📝 学習記録の管理

### 日次学習ログ

`learning-log/`ディレクトリに日付ごとのログファイルを作成：

```bash
# 今日の日付でログファイル作成
cp learning-log/2025-10-20.md learning-log/$(date +%Y-%m-%d).md
```

### 進捗チェックリスト

`learning-progress.md`で全体の進捗を管理：

- [ ] Phase 0-01: GCP CLI基本操作
- [x] Phase 0-02: BigQuery高度な機能（完了例）
- [ ] ...

## 🛠️ ハンズオンで使用するGCPプロジェクト

### 推奨設定

- **プロジェクトID**: `my-project-prd`（または任意の名前）
- **リージョン**: `asia-northeast1`（東京）
- **テスト用データセット**: `learning_dev`

### コスト管理

```bash
# 予算アラートの設定を推奨
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Learning Budget" \
  --budget-amount=5000JPY \
  --threshold-rule=percent=50
```

## 🔒 セキュリティ注意事項

⚠️ **絶対にコミットしてはいけないファイル**:

- GCPサービスアカウントキー（`*.json`）
- Terraformステートファイル（`*.tfstate`）
- 認証情報（`.env`, `credentials.*`）
- BigQuery接続設定（`profiles.yml`）

→ `.gitignore`に追加済み

## 📚 参考リソース

### 公式ドキュメント

- [Google Cloud Documentation](https://cloud.google.com/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [dbt Documentation](https://docs.getdbt.com/)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### コミュニティ

- [dbt Community Slack](https://www.getdbt.com/community/join-the-community)
- [BigQuery User Group Japan](https://bgug.connpass.com/)

## ❓ トラブルシューティング

### gcloud認証エラー

```bash
# 認証をリセット
gcloud auth revoke
gcloud auth login
```

### BigQueryクエリがコスト高

- パーティションフィルタを使用（`WHERE date >= '2025-01-01'`）
- `--dry_run`でスキャン量を事前確認
- クラスタリングキーを活用

### dbt実行エラー

```bash
# 接続テスト
dbt debug

# モデルの依存関係確認
dbt list --models +model_name+
```

## 📞 サポート

質問や問題がある場合：

1. [Issues](../../issues) で質問・バグ報告
2. 学習ロードマップの該当セクションを再確認
3. 公式ドキュメントを参照
4. コミュニティで質問（dbt Slack、Stack Overflow）

## 🤝 貢献

貢献を歓迎します！詳細は [CONTRIBUTING.md](./CONTRIBUTING.md) を参照してください。

## 📁 ディレクトリ構造の詳細

詳細なディレクトリ構造は [ディレクトリ構造セクション](#📁-ディレクトリ構造) を参照してください。

- バグ報告
- 機能提案
- ドキュメント改善
- 誤字・脱字の修正

## 📄 ライセンス

このプロジェクトは [MIT License](./LICENSE) の下で公開されています。

## 🙏 謝辞

- [BigQuery Public Datasets](https://cloud.google.com/bigquery/public-data) - 学習用データの提供
- [dbt Community](https://www.getdbt.com/community/) - データ変換のベストプラクティス
- [Claude Code](https://claude.ai/claude-code) - AI支援学習環境

---

**Good luck with your learning journey! 🚀**
