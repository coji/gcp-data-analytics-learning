# Phase 1-06: dbt（データ変換ツール）

## 📖 学習目標

dbt（data build tool）を使って、SQLによるデータ変換をバージョン管理・テスト・ドキュメント化する方法を習得する。

### このセクションで学ぶこと

- dbtの基本概念（models, sources, tests, materialization）
- dbtプロジェクトの作成と設定
- Staging LayerとMart Layerのモデル作成
- インクリメンタル更新の実装
- データ品質テスト

## 📚 学習リソース

### 公式チュートリアル（必修）

- [dbt Learn - dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals)（2-3時間）

### 公式ドキュメント

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

### 日本語リソース

- [Qiita - dbt入門](https://qiita.com/search?q=dbt)
- [Zenn - dbtトピック](https://zenn.dev/topics/dbt)

## 🎓 dbtの基本概念

### dbtとは

「データ変換をSQLで定義し、バージョン管理・テスト・ドキュメント化を一元管理するツール」

### 主要な概念

| 概念 | 説明 | 例 |
|------|------|---|
| **models** | SQLファイルで定義する変換ロジック | `stg_ads_platform_a.sql` |
| **sources** | 元となるRawデータの定義 | `_sources.yml` |
| **tests** | データ品質チェック | `not_null`, `unique` |
| **materialization** | テーブル/ビュー/インクリメンタルの選択 | `materialized='incremental'` |
| **refs** | モデル間の依存関係 | `{{ ref('stg_ads') }}` |

### dbtプロジェクト構造

```
learning_analytics/
├── dbt_project.yml      # プロジェクト設定
├── profiles.yml         # BigQuery接続設定
├── models/
│   ├── staging/         # Staging Layer
│   │   ├── _sources.yml # 元データ定義
│   │   └── stg_test_ads.sql
│   └── marts/           # Mart Layer
│       └── mart_creative_performance.sql
└── macros/              # 再利用可能な関数
```

## 🚀 ハンズオン演習

### 前提条件

```bash
# dbtのインストール
pip install dbt-bigquery

# バージョン確認
dbt --version
```

### 演習1: dbtプロジェクトの作成

```bash
# 1. dbtプロジェクト作成
cd phase1-integration/06-dbt
dbt init learning_analytics

# 2. プロジェクトディレクトリに移動
cd learning_analytics

# 3. profiles.ymlの設定（~/.dbt/profiles.yml）
# （下記の「profiles.yml設定例」を参照）

# 4. 接続テスト
dbt debug
```

### profiles.yml設定例

`~/.dbt/profiles.yml`に以下を追加：

```yaml
learning_analytics:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: YOUR_PROJECT_ID
      dataset: learning_dev
      location: asia-northeast1
      threads: 4
```

### 演習2: 初めてのdbtモデル

```bash
# 1. Sourcesの定義
mkdir -p models/staging
```

`models/staging/_sources.yml`:

```yaml
version: 2

sources:
  - name: raw
    database: YOUR_PROJECT_ID
    schema: learning_dev
    tables:
      - name: test_ads
        description: "テスト用広告データ"
```

`models/staging/stg_test_ads.sql`:

```sql
{{
  config(
    materialized='view'
  )
}}

SELECT
  date,
  media_source,
  SUM(cost) as total_cost,
  SUM(impressions) as total_impressions,
  ROUND(SAFE_DIVIDE(SUM(cost), SUM(impressions)) * 1000, 2) as cpm
FROM {{ source('raw', 'test_ads') }}
GROUP BY date, media_source
```

```bash
# 2. dbt実行
dbt run --models stg_test_ads

# 3. BigQueryで確認
bq query --use_legacy_sql=false \
  'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.stg_test_ads` LIMIT 10'
```

### 演習3: インクリメンタルモデル

`models/staging/stg_ads_incremental.sql`:

```sql
{{
  config(
    materialized='incremental',
    unique_key='id',
    partition_by={'field': 'date', 'data_type': 'date'}
  )
}}

SELECT
  {{ dbt_utils.generate_surrogate_key(['date', 'media_source', 'campaign_id']) }} as id,
  date,
  media_source,
  campaign_id,
  cost,
  impressions
FROM {{ source('raw', 'test_ads') }}

{% if is_incremental() %}
  -- 前回実行以降の新規データのみ処理
  WHERE date > (SELECT MAX(date) FROM {{ this }})
{% endif %}
```

```bash
# 初回実行（全データ）
dbt run --models stg_ads_incremental

# 2回目実行（差分のみ）
dbt run --models stg_ads_incremental
```

### 演習4: データ品質テスト

`models/staging/_schema.yml`:

```yaml
version: 2

models:
  - name: stg_test_ads
    description: "テスト広告データ（Staging）"
    columns:
      - name: date
        description: "レポート日付"
        tests:
          - not_null
      - name: media_source
        description: "広告媒体名"
        tests:
          - not_null
      - name: total_cost
        description: "合計広告費"
        tests:
          - not_null
```

```bash
# テスト実行
dbt test --models stg_test_ads
```

## 📝 演習課題

### 課題1: dbt Fundamentalsコース完了

[dbt Learn](https://learn.getdbt.com/courses/dbt-fundamentals)のコースを完了してください（2-3時間）

### 課題2: dbtプロジェクト設計の理解

学習ロードマップの「dbtプロジェクト設計」（728-838行目）を読み、以下を理解：

1. なぜmodelsを`staging/`と`marts/`に分けるのか？
2. `_sources.yml`の役割は？
3. `dbt_project.yml`の設定項目の意味

### 課題3: stg_ads_platform_a.sqlの解読

学習ロードマップの`stg_ads_platform_a.sql`（281-343行目）を読み、以下を説明：

1. `config()`の各オプションの意味
2. `{{ dbt_utils.generate_surrogate_key() }}`の役割
3. `SAFE_DIVIDE()`を使う理由
4. インクリメンタル処理の仕組み

### 課題4: 自分でインクリメンタルモデルを作成

1. 新しいインクリメンタルモデルを作成
2. 初回実行（全データ処理）
3. データを追加
4. 2回目実行（差分のみ処理）
5. 処理されたデータを確認

## ✅ 完了チェックリスト

- [ ] dbtのインストール
- [ ] dbtの基本概念理解
- [ ] dbtプロジェクト作成
- [ ] profiles.yml設定
- [ ] `dbt debug`で接続成功
- [ ] Sourcesの定義
- [ ] 初めてのモデル作成と実行
- [ ] インクリメンタルモデル作成
- [ ] データ品質テスト実行
- [ ] 課題1: dbt Fundamentalsコース完了
- [ ] 課題2: プロジェクト設計理解
- [ ] 課題3: SQL解読完了
- [ ] 課題4: インクリメンタルモデル作成完了

## 🔗 次のステップ

完了したら、[Phase 1-07: AppsFlyer PBA](../07-appsflyer-pba/README.md)に進んでください。

## 📌 dbtのベストプラクティス

### 1. Stagingモデルの役割

- 1つのSourceにつき1つのStagingモデル
- カラム名のリネームと型変換
- 基本的なクリーニングのみ

### 2. Martモデルの役割

- 複数のStagingモデルを結合
- ビジネスロジックの適用
- 集計・計算

### 3. Materialization の選択

- **view**: 計算コストが低く、常に最新データが必要
- **table**: 頻繁にアクセスされ、計算コストが高い
- **incremental**: 大量データで差分更新が必要

### 4. テストの書き方

```yaml
models:
  - name: stg_ads
    columns:
      - name: id
        tests:
          - unique
          - not_null
      - name: cost
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

## ❓ トラブルシューティング

### dbt debugでエラー

```bash
# 認証情報の再取得
gcloud auth application-default login

# profiles.ymlの確認
cat ~/.dbt/profiles.yml
```

### モデル実行エラー

```bash
# 詳細ログを確認
dbt run --models MODEL_NAME --debug

# 依存関係を確認
dbt list --models +MODEL_NAME+
```

### BigQuery権限エラー

- `bigquery.dataEditor`または`bigquery.admin`が必要
- データセットへのアクセス権を確認
