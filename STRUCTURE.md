# プロジェクト構造ガイド

このドキュメントは、リポジトリの構造と各ディレクトリの役割を説明します。

## 📁 ディレクトリ構造

```
gcloud/
├── 📄 README.md                   # プロジェクト概要とクイックスタート
├── 📄 LICENSE                     # MITライセンス
├── 📄 CONTRIBUTING.md             # 貢献ガイドライン
├── 📄 learning-progress.md        # 学習進捗チェックリスト
│
├── 📂 docs/                       # 📚 すべてのドキュメント
│   ├── README.md                  # ドキュメント一覧
│   ├── GETTING-STARTED.md         # クイックスタートガイド ⭐ まずはここから
│   ├── learning-mode-guide.md     # Claude Code学習モード使い方
│   ├── multi-account-setup.md     # 複数アカウント管理
│   ├── sample-data-guide.md       # サンプルデータ詳細
│   ├── CLAUDE.md                  # Claude Code用技術ガイド
│
├── 📂 scripts/                    # 🔧 セットアップスクリプト
│   ├── README.md                  # スクリプト使い方ガイド
│   ├── quickstart-sample-data.sh  # 動作確認用（公開データ使用）
│   ├── setup-learning-data.sh     # 学習データセットセットアップ
│   └── switch-to-learning.sh      # 学習用設定に切り替え
│
├── 📂 config/                     # ⚙️ 設定ファイル例
│   ├── README.md                  # 設定ファイルガイド
│   └── .aliases.example           # シェルエイリアス設定例
│
├── 📂 learning-log/               # 📝 学習記録（日付ごと）
│   └── 2025-10-20.md              # テンプレート
│
├── 📂 phase0-preparation/         # 🎯 Phase 0: 準備・検証（2-3週間）
│   ├── 01-gcp-cli/                # GCP CLIとBigQuery基本
│   ├── 02-bigquery-advanced/      # パーティショニング・クラスタリング
│   ├── 03-data-modeling/          # データモデリング基礎
│   ├── 04-iam-service-accounts/   # IAMとサービスアカウント
│   └── 05-terraform/              # Terraform基礎
│
├── 📂 phase1-integration/         # 🔄 Phase 1: データ統合（1-1.5ヶ月）
│   ├── 06-dbt/                    # dbt（データ変換）
│   ├── 07-appsflyer-pba/          # AppsFlyer連携
│   └── 08-data-integration/       # データ統合パターン
│
└── 📂 phase2-analytics/           # 📊 Phase 2: 分析（継続的）
    ├── 09-advanced-sql/           # 高度なSQL（LTV、コホート分析）
    ├── 10-bi-tools/               # BIツール連携
    ├── 11-cloud-scheduler/        # スケジューリング
    └── 12-monitoring/             # モニタリング
```

## 🎯 目的別ナビゲーション

### 🚀 初めての方

1. **[README.md](README.md)** - プロジェクト全体の概要
2. **[docs/GETTING-STARTED.md](docs/GETTING-STARTED.md)** - 5分で学習開始
3. **[docs/learning-mode-guide.md](docs/learning-mode-guide.md)** - Claude Codeの使い方
4. **[learning-progress.md](learning-progress.md)** - 自分の進捗を記録

### 📚 学習中の方

- **各Phaseのディレクトリ** - `phase0-preparation/`, `phase1-integration/`, `phase2-analytics/`
  - 各ディレクトリ内の `README.md` に学習内容と演習が記載
  - `exercises.md` に演習メモを記録
  - `commands-log.sh` で実際のコマンドを実行

### 🔧 環境セットアップ

- **[scripts/README.md](scripts/README.md)** - スクリプト使い方
- **[docs/multi-account-setup.md](docs/multi-account-setup.md)** - 複数アカウント管理
- **[config/README.md](config/README.md)** - エイリアス設定

### 🤝 貢献したい方

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - 貢献ガイドライン
- **[docs/CLAUDE.md](docs/CLAUDE.md)** - 技術仕様

## 📋 各ディレクトリの役割

### ルートレベル

| ファイル/ディレクトリ | 役割 | 重要度 |
|---------------------|------|--------|
| `README.md` | プロジェクト概要、クイックスタート | ⭐⭐⭐ |
| `LICENSE` | MITライセンス | ⭐ |
| `CONTRIBUTING.md` | 貢献ガイドライン | ⭐⭐ |
| `learning-progress.md` | 進捗チェックリスト | ⭐⭐⭐ |
| `docs/` | すべてのドキュメント | ⭐⭐⭐ |
| `scripts/` | セットアップスクリプト | ⭐⭐⭐ |
| `config/` | 設定ファイル例 | ⭐⭐ |
| `learning-log/` | 学習記録 | ⭐⭐ |
| `phase*/` | 学習コンテンツ | ⭐⭐⭐ |

### docs/ - ドキュメント

| ファイル | 役割 | いつ読む？ |
|---------|------|-----------|
| `README.md` | ドキュメント一覧 | 最初に |
| `GETTING-STARTED.md` | クイックスタート | 最初に⭐ |
| `learning-mode-guide.md` | Claude Code使い方 | 最初に⭐ |
| `multi-account-setup.md` | アカウント管理 | 複数アカウント使用時 |
| `sample-data-guide.md` | データセット詳細 | 演習開始前 |
| `CLAUDE.md` | 技術仕様 | Claude Code開発時 |

### scripts/ - スクリプト

| スクリプト | 用途 | 実行タイミング |
|----------|------|---------------|
| `quickstart-sample-data.sh` | 動作確認 | 初回・動作確認時 |
| `setup-learning-data.sh` | データセットセットアップ | 演習開始前 |
| `switch-to-learning.sh` | 学習用設定に切り替え | 学習開始時・毎回 |

### config/ - 設定ファイル

| ファイル | 用途 | 使い方 |
|---------|------|--------|
| `.aliases.example` | エイリアス設定例 | `~/.bashrc`にコピー |

### phase*/ - 学習フェーズ

各Phaseディレクトリには以下が含まれます：

```
phase0-preparation/01-gcp-cli/
├── README.md           # 学習ガイドと演習
├── exercises.md        # 演習メモ用テンプレート
└── commands-log.sh     # 実行コマンド集
```

## 🔄 学習フロー

```
1. README.md で全体像を把握
   ↓
2. docs/GETTING-STARTED.md で環境構築
   ↓
3. scripts/switch-to-learning.sh で学習用設定に切り替え
   ↓
4. scripts/setup-learning-data.sh でデータセットセットアップ
   ↓
5. phase0-preparation/01-gcp-cli/ から順番に学習
   ↓
6. learning-progress.md で進捗を記録
   ↓
7. learning-log/ に日々の学習を記録
```

## 💡 ベストプラクティス

### ファイル管理

1. **ドキュメントを読む時**: `docs/` ディレクトリから探す
2. **スクリプトを実行する時**: `scripts/` ディレクトリから実行
3. **設定をカスタマイズする時**: `config/` の `.example` ファイルをコピー

### 学習記録

1. **進捗管理**: `learning-progress.md` にチェックマーク
2. **日次ログ**: `learning-log/YYYY-MM-DD.md` に詳細を記録
3. **演習メモ**: 各Phase の `exercises.md` に記録

### Git管理

```bash
# 学習記録のみコミット
git add learning-progress.md
git add learning-log/2025-10-20.md
git add phase0-preparation/01-gcp-cli/exercises.md
git commit -m "Update learning progress: Phase 0-01 completed"
```

## 🔙 関連リンク

- [README.md](README.md) - プロジェクトルート
- [docs/README.md](docs/README.md) - ドキュメント一覧
- [scripts/README.md](scripts/README.md) - スクリプトガイド
- [config/README.md](config/README.md) - 設定ガイド
