-- Phase 0-02: パーティション分割の効果を比較するクエリ集
-- thelook_ecommerce データセットを使用

-- ============================================
-- 1. パーティションフィルタありのクエリ
-- ============================================

-- 特定日のイベント集計（パーティションフィルタあり）
SELECT
  traffic_source,
  event_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT session_id) as unique_sessions
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_date = "2024-01-01"  -- パーティションキーでフィルタ
GROUP BY traffic_source, event_type
ORDER BY event_count DESC;

-- ============================================
-- 2. パーティションフィルタなしのクエリ
-- ============================================

-- パーティション以外のカラムでフィルタ（スキャン量が多い）
SELECT
  traffic_source,
  event_type,
  COUNT(*) as event_count
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_type = "purchase"  -- パーティションキー以外でフィルタ
GROUP BY traffic_source, event_type
ORDER BY event_count DESC;

-- ============================================
-- 3. パーティション + クラスタリングを活用
-- ============================================

-- パーティションとクラスタリングキーの両方でフィルタ（最も効率的）
SELECT
  event_date,
  traffic_source,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_date BETWEEN "2024-01-01" AND "2024-01-07"  -- パーティションフィルタ
  AND traffic_source IN ("Email", "Adwords")            -- クラスタリングフィルタ
GROUP BY event_date, traffic_source
ORDER BY event_date, event_count DESC;

-- ============================================
-- 4. 日付範囲指定のクエリ
-- ============================================

-- 1週間のデータ集計
SELECT
  event_date,
  COUNT(DISTINCT session_id) as sessions,
  COUNT(CASE WHEN event_type = "product" THEN 1 END) as product_views,
  COUNT(CASE WHEN event_type = "cart" THEN 1 END) as add_to_carts,
  COUNT(CASE WHEN event_type = "purchase" THEN 1 END) as purchases,
  ROUND(SAFE_DIVIDE(
    COUNT(CASE WHEN event_type = "purchase" THEN 1 END),
    COUNT(DISTINCT session_id)
  ) * 100, 2) as cvr_percent
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_date BETWEEN "2024-01-01" AND "2024-01-07"
GROUP BY event_date
ORDER BY event_date;

-- ============================================
-- 5. パーティション情報の確認クエリ
-- ============================================

-- パーティション別のデータ量確認
SELECT
  partition_id,
  total_rows,
  ROUND(total_logical_bytes / 1024 / 1024, 2) as size_mb
FROM `YOUR_PROJECT_ID.learning_dev.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = "events_partitioned"
  AND partition_id IS NOT NULL
ORDER BY partition_id DESC
LIMIT 31;  -- 直近31日分

-- ============================================
-- 6. クラスタリング効果の確認
-- ============================================

-- クラスタリングキー（traffic_source）でフィルタ
SELECT
  event_date,
  event_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_date = "2024-01-01"
  AND traffic_source = "Email"  -- クラスタリングキーでフィルタ
GROUP BY event_date, event_type
ORDER BY event_count DESC;

-- ============================================
-- 7. 悪い例：パーティションを活用しないクエリ
-- ============================================

-- ❌ パーティションキーを関数で加工（パーティションプルーニングが効かない）
-- SELECT *
-- FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
-- WHERE EXTRACT(MONTH FROM event_date) = 1;  -- 悪い例

-- ✅ 正しい例：範囲指定
SELECT *
FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
WHERE event_date BETWEEN "2024-01-01" AND "2024-01-31";

-- ============================================
-- スキャン量比較のためのドライラン実行例
-- ============================================

-- ターミナルで以下を実行して比較：
--
-- # パーティションフィルタあり
-- bq query --use_legacy_sql=false --dry_run \
--   'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`
--    WHERE event_date = "2024-01-01"'
--
-- # パーティションフィルタなし
-- bq query --use_legacy_sql=false --dry_run \
--   'SELECT * FROM `YOUR_PROJECT_ID.learning_dev.events_partitioned`'
--
-- スキャン量の違いを確認してください！
