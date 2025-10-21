# Phase 0-03: データモデリングの基礎（3層アーキテクチャ）

## 📖 学習目標

データウェアハウスを「Raw（生データ）」「Staging（標準化）」「Mart（分析用）」の3層に分けて設計する手法を理解する。

### このセクションで学ぶこと

- 3層アーキテクチャの概念
- 各レイヤーの役割と責任範囲
- データフロー全体の理解
- 実際のプロジェクトでの適用方法

## 📚 学習リソース

### 推奨記事

- [dbt Labs - Best practices for data modeling](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview)
- [Snowflake - Data modeling best practices](https://www.snowflake.com/guides/data-modeling/)

### 書籍

- 「The Data Warehouse Toolkit」（Ralph Kimball）
- 「データマネジメントが30分でわかる本」

## 🎓 3層アーキテクチャの概要

### レイヤーの役割

| レイヤー | 目的 | 特徴 | 保持期間 |
|---------|------|------|----------|
| **Raw Layer** | データソースからの生データを最小限の変換で格納 | Immutable（変更不可）<br>パーティション分割 | 90日 |
| **Staging Layer** | クリーニング、標準化、データ品質チェック | dbtで管理<br>統一スキーマ | 180日 |
| **Mart Layer** | ビジネスロジックを含む集計・結合済みデータ | 事前集計<br>BIツールから直接参照 | 無期限 |

### データフロー図

```
[外部API/サービス]
  ↓
[Raw Layer: 生データ格納]
  - raw_marketing_ads_platform_a
  - raw_marketing_mobile_app
  ↓ (dbt transform)
[Staging Layer: 標準化]
  - stg_ads_platform_a
  - stg_mobile_app_installs
  ↓ (dbt transform)
[Mart Layer: 分析用]
  - mart_creative_performance
  - mart_user_journey
  ↓
[BI Tools: Metabase/Looker Studio]
```

## 📝 演習課題

### 課題1: 各レイヤーの責任範囲をまとめる

学習ロードマップの「3層アーキテクチャ詳細」（192-450行目）を読み、以下を`learning-log/YYYY-MM-DD.md`にまとめてください：

1. **Raw Layer**の責任範囲
   - 何をする？何をしない？
   - なぜImmutable（変更不可）なのか？

2. **Staging Layer**の責任範囲
   - どのような変換を行う？
   - なぜdbtで管理するのか？

3. **Mart Layer**の責任範囲
   - どのようなビジネスロジックを含む？
   - なぜ事前集計するのか？

### 課題2: 自分の分析領域でのテーブル設計

自分が担当する分析領域（例: プラットフォームA広告のクリエイティブ分析）について、3層それぞれでどんなテーブルが必要かを設計してください。

**テンプレート（`learning-log/YYYY-MM-DD.md`に記録）**:

```
## 分析領域: [分析のテーマ]

### Raw Layer
- テーブル名: raw_xxx_yyy
- データソース: [API名/サービス名]
- 主要カラム: [カラムリスト]
- 更新頻度: [日次/時間ごと等]

### Staging Layer
- テーブル名: stg_xxx
- 変換内容: [どのようなクリーニング/標準化を行うか]
- 主要カラム: [カラムリスト]

### Mart Layer
- テーブル名: mart_xxx
- ビジネスロジック: [どのような集計/計算を行うか]
- 想定される分析: [このテーブルで何を分析するか]
```

### 課題3: mart_creative_performance.sqlの解読

学習ロードマップの`mart_creative_performance.sql`（357-449行目）のSQLを読み、以下を説明してください：

1. どのようなビジネスロジックが含まれているか（箇条書き）
2. なぜLEFT JOINを使っているのか
3. SAFE_DIVIDE()を使う理由
4. このMartテーブルでどのような分析ができるか

## ✅ 完了チェックリスト

- [ ] Raw Layerの役割理解
- [ ] Staging Layerの役割理解
- [ ] Mart Layerの役割理解
- [ ] データフロー全体の理解
- [ ] 課題1: 各レイヤーの責任範囲まとめ完了
- [ ] 課題2: 自分の分析領域でのテーブル設計完了
- [ ] 課題3: mart_creative_performance.sqlの解読完了

## 🔗 次のステップ

完了したら、[Phase 0-04: サービスアカウントとIAM設計](../04-iam-service-accounts/README.md)に進んでください。

## 📌 設計のベストプラクティス

### Raw Layerの原則

1. **Immutable**: 一度書き込んだデータは変更しない
2. **Minimal Transformation**: API/サービスからのデータをほぼそのまま格納
3. **Audit Trail**: いつ、どこから取得したデータかを記録

### Staging Layerの原則

1. **Standardization**: 複数のソースを統一スキーマに変換
2. **Data Quality**: NULLチェック、データ型の整合性確認
3. **Reusability**: 複数のMartで再利用可能な形に整形

### Mart Layerの原則

1. **Business Logic**: ビジネスの定義に基づく計算（LTV、ROI等）
2. **Pre-aggregation**: BIツールの負荷を減らすため事前集計
3. **User-friendly**: アナリストが理解しやすいカラム名・構造

## ❓ よくある質問

### Q: なぜ3層も必要なのか？2層ではダメか？

A:

- Raw層がないと、データ品質問題が起きた時に遡って調査できない
- Staging層がないと、各Martで同じ変換ロジックを重複して書くことになる
- Mart層がないと、BIツールで複雑なSQLを書く必要があり、パフォーマンスが悪化

### Q: dbtがない場合はどうするか？

A:

- Scheduled Queryでも同様の構造は実現可能
- ただし、バージョン管理、テスト、ドキュメント生成の機能がないため、dbtの利用を強く推奨

### Q: Mart層は常にテーブルにすべきか？

A:

- 頻繁にアクセスされるMart: テーブル（materialized='table'）
- 計算コストが低いMart: ビュー（materialized='view'）
- 差分更新が必要なMart: インクリメンタル（materialized='incremental'）
