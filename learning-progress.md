# 学習進捗チェックリスト

**最終更新**: 2025-10-20
**学習開始日**: 2025-10-20

## 📊 全体進捗

- Phase 0: 0/5 完了 (0%)
- Phase 1: 0/3 完了 (0%)
- Phase 2: 0/4 完了 (0%)
- **合計**: 0/12 完了 (0%)

---

## Phase 0: 準備・検証で必要な技術

**目標期間**: Week 1-2（2-3週間）
**目的**: GCPとBigQueryの基礎を固め、開発環境を構築する

### 01. GCP CLI（gcloud, bq）の基本操作

- [ ] gcloud CLIのインストールと認証
- [ ] プロジェクト設定（`gcloud config set project`）
- [ ] データセット一覧取得（`bq ls`）
- [ ] テーブルスキーマ確認（`bq show --schema`）
- [ ] クエリ実行（`bq query`）
- [ ] データセット作成・削除
- [ ] **演習課題1**: 既存データセットのリストアップと役割理解
- [ ] **演習課題2**: 過去30日間の広告費集計クエリ作成
- [ ] **演習課題3**: テストデータセット作成とサンプルテーブルコピー

**学習リソース**:
- [ ] [gcloud CLIの概要](https://cloud.google.com/sdk/gcloud)を読む
- [ ] [bqコマンドリファレンス](https://cloud.google.com/bigquery/docs/bq-command-line-tool)を読む

---

### 02. BigQuery 高度な機能

- [ ] パーティション分割テーブルの理解
- [ ] クラスター化テーブルの理解
- [ ] 外部データソース（GCS連携）の理解
- [ ] IAM権限設計の基礎
- [ ] **ハンズオン1**: パーティション分割テーブル作成
- [ ] **ハンズオン2**: クエリの`--dry_run`でスキャン量確認
- [ ] **ハンズオン3**: IAM権限の確認
- [ ] **演習課題1**: パーティション・クラスタリング設定の意図説明
- [ ] **演習課題2**: 30日後自動削除のパーティションテーブル作成
- [ ] **演習課題3**: パーティションフィルタの有無でスキャン量比較

**学習リソース**:
- [ ] [パーティション分割テーブル](https://cloud.google.com/bigquery/docs/partitioned-tables)を読む
- [ ] [クラスター化テーブル](https://cloud.google.com/bigquery/docs/clustered-tables)を読む
- [ ] [BigQuery IAM](https://cloud.google.com/bigquery/docs/access-control)を読む
- [ ] Coursera - Modernizing Data Lakes and Data Warehouses with GCP

---

### 03. データモデリングの基礎（3層アーキテクチャ）

- [ ] Raw Layerの役割理解
- [ ] Staging Layerの役割理解
- [ ] Mart Layerの役割理解
- [ ] データフロー全体の理解
- [ ] **演習課題1**: 各レイヤーの責任範囲をノートにまとめる
- [ ] **演習課題2**: 自分の分析領域で必要なテーブル設計
- [ ] **演習課題3**: `mart_creative_performance.sql`のビジネスロジック説明

**学習リソース**:
- [ ] [dbt Labs - Best practices for data modeling](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)を読む
- [ ] 学習ロードマップの「3層アーキテクチャ詳細」セクションを熟読

---

### 04. サービスアカウントとIAM設計

- [ ] サービスアカウントの概念理解
- [ ] 最小権限の原則の理解
- [ ] **ハンズオン**: サービスアカウント作成
- [ ] **ハンズオン**: データセットへの権限付与
- [ ] **ハンズオン**: 権限確認
- [ ] **演習課題1**: 各サービスアカウントの権限設計意図説明
- [ ] **演習課題2**: 開発用サービスアカウント作成と権限付与
- [ ] **演習課題3**: セキュリティリスクの考察

**学習リソース**:
- [ ] [サービスアカウントの概要](https://cloud.google.com/iam/docs/service-accounts)を読む
- [ ] [BigQuery IAMロール](https://cloud.google.com/bigquery/docs/access-control)を読む
- [ ] [IAM best practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)を読む

---

### 05. Terraform基礎（インフラのコード管理）

- [ ] Terraformのインストール
- [ ] Infrastructure as Code（IaC）の概念理解
- [ ] Terraformの基本構成理解（provider, resource, variable）
- [ ] **ハンズオン**: `terraform init`
- [ ] **ハンズオン**: `terraform plan`の実行と理解
- [ ] **ハンズオン**: `terraform apply`でリソース作成
- [ ] **ハンズオン**: `terraform destroy`でクリーンアップ
- [ ] **演習課題1**: Terraformのメリットを3つ挙げる
- [ ] **演習課題2**: `terraform plan`の出力内容を理解
- [ ] **演習課題3**: サービスアカウント作成のTerraformコード作成

**学習リソース**:
- [ ] [Terraform - Get Started with Google Cloud](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)を完了
- [ ] 学習ロードマップの「Terraformによるインフラ管理」セクションを読む

---

## Phase 1: データ統合基盤で必要な技術

**目標期間**: Week 3-6（1-1.5ヶ月）
**目的**: 実際のデータパイプラインを構築し、dbtを習得する

### 06. dbt（データ変換ツール）

- [ ] dbtのインストール（`pip install dbt-bigquery`）
- [ ] dbtの基本概念理解（models, sources, tests, materialization, refs）
- [ ] **ハンズオン**: `dbt init`でプロジェクト作成
- [ ] **ハンズオン**: `profiles.yml`の設定
- [ ] **ハンズオン**: `dbt debug`で接続テスト
- [ ] **ハンズオン**: サンプルモデル作成と実行
- [ ] **ハンズオン**: `sources.yml`の作成
- [ ] インクリメンタル更新の理解
- [ ] **演習課題1**: dbt Fundamentalsコース完了（2-3時間）
- [ ] **演習課題2**: dbtプロジェクト設計の理解
- [ ] **演習課題3**: `stg_ads_platform_a.sql`の解読
- [ ] **演習課題4**: インクリメンタルモデル作成と差分処理確認

**学習リソース**:
- [ ] [dbt Learn - dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals)を完了（必修）
- [ ] [dbt Documentation](https://docs.getdbt.com/docs/introduction)を読む

---

### 07. AppsFlyer PBA（People-Based Attribution）

- [ ] AppsFlyerの概要理解
- [ ] PBA（People-Based Attribution）の仕組み理解
- [ ] Customer User IDの重要性理解
- [ ] Data Lockerの概念理解
- [ ] **演習課題1**: PBA導入手順をステップバイステップでノートにまとめる
- [ ] **演習課題2**: Customer User IDの仕組み理解
- [ ] **演習課題3**: Hiveパーティションの概念理解
- [ ] **演習課題4**: 検証SQLクエリの理解

**学習リソース**:
- [ ] [AppsFlyer - PBA Overview](https://support.appsflyer.com/hc/en-us/articles/360001294118)を読む
- [ ] [AppsFlyer - Web SDK Integration](https://dev.appsflyer.com/hc/docs/web-sdk)を読む
- [ ] [AppsFlyer - Data Locker](https://support.appsflyer.com/hc/en-us/articles/360011596839)を読む

---

### 08. データ統合ツール（Databeat / Fivetran）

- [ ] Databeatの概要理解
- [ ] Fivetranの概要理解
- [ ] Databeatセットアップフロー理解
- [ ] スキーマ標準化の仕組み理解
- [ ] **演習課題1**: Databeatセットアップ手順の理解
- [ ] **演習課題2**: Databeatデモ動画視聴
- [ ] **演習課題3**: DatabeatとFivetranの比較（コスト、サポート、対応媒体）
- [ ] **実践**: Databeatトライアル申し込みとテスト（任意）

**学習リソース**:
- [ ] [Databeat公式サイト](https://databeat.io/)を確認
- [ ] [Fivetran公式ドキュメント](https://fivetran.com/docs)を確認

---

## Phase 2: 分析テンプレート構築で必要な技術

**目標期間**: Week 7-8以降（継続的に）
**目的**: 運用レベルの実装とダッシュボード構築

### 09. 高度なSQL（LTV計算、ウィンドウ関数）

- [ ] LTV計算ロジックの理解
- [ ] ウィンドウ関数の理解（`ROW_NUMBER()`, `RANK()`, `LAG()`, `LEAD()`）
- [ ] コホート分析の理解
- [ ] ROI計算の理解
- [ ] **演習課題1**: `mart_creative_performance.sql`の解読
- [ ] **演習課題2**: 7日LTVと30日LTV計算クエリ作成
- [ ] **演習課題3**: `EXPLAIN`で実行計画確認とパフォーマンス改善

**学習リソース**:
- [ ] [Mode Analytics - SQL Tutorial](https://mode.com/sql-tutorial/)を完了
- [ ] 「ビッグデータ分析・活用のためのSQLレシピ」を読む（推奨）

---

### 10. Metabase / Looker Studio（BIツール）

- [ ] Metabaseの概要理解
- [ ] Looker Studioの概要理解
- [ ] **ハンズオン**: MetabaseをローカルでBigQuery接続
- [ ] **ハンズオン**: クリエイティブ別LTVの棒グラフ作成
- [ ] **演習課題**: Looker Studioで同じダッシュボード作成と比較

**学習リソース**:
- [ ] [Metabase公式ドキュメント](https://www.metabase.com/docs/latest/)を読む
- [ ] [Metabase - BigQuery連携](https://www.metabase.com/docs/latest/administration-guide/databases/bigquery.html)を読む
- [ ] [Looker Studio - BigQuery連携](https://support.google.com/looker-studio/answer/6370296)を読む

---

### 11. Cloud Scheduler（スケジュール実行）

- [ ] Cloud Schedulerの概要理解
- [ ] Cron構文の理解
- [ ] **演習課題1**: サンプリング自動化の理解
- [ ] **演習課題2**: サンプルジョブ作成と手動実行

**学習リソース**:
- [ ] [Cloud Scheduler - Quickstart](https://cloud.google.com/scheduler/docs/quickstart)を読む

---

### 12. 監視・アラート（Datadog / Cloud Monitoring）

- [ ] データパイプライン監視の重要性理解
- [ ] ETLフェイル検知の仕組み理解
- [ ] RTO（復旧目標時間）の概念理解
- [ ] **演習課題1**: BigQueryジョブ失敗アラート作成
- [ ] **演習課題2**: dbtテスト失敗時のSlack通知調査

**学習リソース**:
- [ ] [Datadog - BigQuery Integration](https://docs.datadoghq.com/integrations/google_cloud_big_query/)を読む
- [ ] [Cloud Monitoring - Quickstart](https://cloud.google.com/monitoring/docs/quickstart)を読む

---

## 🎓 修了条件

以下をすべて完了したら、このロードマップは修了です：

- [ ] Phase 0の全5項目完了
- [ ] Phase 1の全3項目完了
- [ ] Phase 2の全4項目完了
- [ ] dbtで実際のデータパイプライン構築（Raw → Staging → Mart）
- [ ] Terraformでインフラをコード化
- [ ] BIツールでダッシュボード作成
- [ ] 監視・アラート設定

---

## 📝 メモ欄

### 学習で特に重要だったポイント

（学習しながら追記していく）

### つまずいたポイントと解決策

（学習しながら追記していく）

### 次に深掘りしたいトピック

（学習しながら追記していく）
