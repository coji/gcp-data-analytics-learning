-- Phase 2-09: コホート分析クエリ
-- thelook_ecommerce データセットを使用

-- ============================================
-- 1. 月次コホートのリテンション率
-- ============================================

WITH cohort_base AS (
  -- 各ユーザーの初回注文月（コホート）を定義
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), MONTH) AS cohort_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

cohort_activity AS (
  -- 各ユーザーのアクティビティ月を取得
  SELECT
    cb.cohort_month,
    cb.user_id,
    DATE_TRUNC(o.created_at, MONTH) AS activity_month,
    DATE_DIFF(DATE_TRUNC(o.created_at, MONTH), cb.cohort_month, MONTH) AS months_since_cohort
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  WHERE o.status = 'Complete'
),

cohort_size AS (
  -- 各コホートのユーザー数
  SELECT
    cohort_month,
    COUNT(DISTINCT user_id) AS cohort_users
  FROM cohort_base
  GROUP BY cohort_month
),

retention AS (
  -- 各月のリテンションユーザー数
  SELECT
    cohort_month,
    months_since_cohort,
    COUNT(DISTINCT user_id) AS retained_users
  FROM cohort_activity
  GROUP BY cohort_month, months_since_cohort
)

SELECT
  r.cohort_month,
  r.months_since_cohort,
  cs.cohort_users,
  r.retained_users,
  ROUND(SAFE_DIVIDE(r.retained_users, cs.cohort_users) * 100, 2) AS retention_rate_percent
FROM retention r
JOIN cohort_size cs
  ON r.cohort_month = cs.cohort_month
WHERE r.cohort_month >= '2023-01-01'  -- 直近2年のコホート
ORDER BY r.cohort_month DESC, r.months_since_cohort;


-- ============================================
-- 2. 週次コホートのリテンション率（詳細分析）
-- ============================================

WITH cohort_base AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), WEEK(MONDAY)) AS cohort_week
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

cohort_activity AS (
  SELECT
    cb.cohort_week,
    cb.user_id,
    DATE_TRUNC(o.created_at, WEEK(MONDAY)) AS activity_week,
    DATE_DIFF(DATE_TRUNC(o.created_at, WEEK(MONDAY)), cb.cohort_week, WEEK) AS weeks_since_cohort
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  WHERE o.status = 'Complete'
),

cohort_size AS (
  SELECT
    cohort_week,
    COUNT(DISTINCT user_id) AS cohort_users
  FROM cohort_base
  GROUP BY cohort_week
),

retention AS (
  SELECT
    cohort_week,
    weeks_since_cohort,
    COUNT(DISTINCT user_id) AS retained_users
  FROM cohort_activity
  GROUP BY cohort_week, weeks_since_cohort
)

SELECT
  r.cohort_week,
  r.weeks_since_cohort,
  cs.cohort_users,
  r.retained_users,
  ROUND(SAFE_DIVIDE(r.retained_users, cs.cohort_users) * 100, 2) AS retention_rate_percent
FROM retention r
JOIN cohort_size cs
  ON r.cohort_week = cs.cohort_week
WHERE r.cohort_week >= '2024-01-01'  -- 直近のコホート
  AND r.weeks_since_cohort <= 12     -- 最初の12週間のみ
ORDER BY r.cohort_week DESC, r.weeks_since_cohort;


-- ============================================
-- 3. 流入元別のコホートリテンション
-- ============================================

WITH user_first_event AS (
  -- 各ユーザーの初回流入元を取得
  SELECT
    user_id,
    ARRAY_AGG(traffic_source ORDER BY created_at LIMIT 1)[OFFSET(0)] AS first_traffic_source
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE user_id IS NOT NULL
  GROUP BY user_id
),

cohort_base AS (
  SELECT
    o.user_id,
    DATE_TRUNC(MIN(o.created_at), MONTH) AS cohort_month,
    ufe.first_traffic_source
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  LEFT JOIN user_first_event ufe
    ON o.user_id = ufe.user_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id, ufe.first_traffic_source
),

cohort_activity AS (
  SELECT
    cb.cohort_month,
    cb.first_traffic_source,
    cb.user_id,
    DATE_DIFF(DATE_TRUNC(o.created_at, MONTH), cb.cohort_month, MONTH) AS months_since_cohort
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  WHERE o.status = 'Complete'
),

retention AS (
  SELECT
    cohort_month,
    first_traffic_source,
    months_since_cohort,
    COUNT(DISTINCT user_id) AS retained_users
  FROM cohort_activity
  GROUP BY cohort_month, first_traffic_source, months_since_cohort
)

SELECT
  cohort_month,
  first_traffic_source,
  months_since_cohort,
  retained_users,
  -- Month 0のユーザー数を基準にリテンション率を計算
  ROUND(SAFE_DIVIDE(
    retained_users,
    MAX(CASE WHEN months_since_cohort = 0 THEN retained_users END) OVER (PARTITION BY cohort_month, first_traffic_source)
  ) * 100, 2) AS retention_rate_percent
FROM retention
WHERE cohort_month >= '2023-01-01'
  AND first_traffic_source IS NOT NULL
ORDER BY cohort_month DESC, first_traffic_source, months_since_cohort;


-- ============================================
-- 4. コホート別の累積売上
-- ============================================

WITH cohort_base AS (
  SELECT
    user_id,
    DATE_TRUNC(MIN(created_at), MONTH) AS cohort_month
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

cohort_revenue AS (
  SELECT
    cb.cohort_month,
    DATE_DIFF(DATE_TRUNC(o.created_at, MONTH), cb.cohort_month, MONTH) AS months_since_cohort,
    SUM(oi.sale_price) AS revenue
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
  GROUP BY cb.cohort_month, months_since_cohort
),

cohort_size AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT user_id) AS cohort_users
  FROM cohort_base
  GROUP BY cohort_month
)

SELECT
  cr.cohort_month,
  cs.cohort_users,
  cr.months_since_cohort,
  ROUND(cr.revenue, 2) AS month_revenue,
  ROUND(SUM(cr.revenue) OVER (
    PARTITION BY cr.cohort_month
    ORDER BY cr.months_since_cohort
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ), 2) AS cumulative_revenue,
  ROUND(SAFE_DIVIDE(cr.revenue, cs.cohort_users), 2) AS revenue_per_user,
  ROUND(SAFE_DIVIDE(
    SUM(cr.revenue) OVER (
      PARTITION BY cr.cohort_month
      ORDER BY cr.months_since_cohort
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ),
    cs.cohort_users
  ), 2) AS cumulative_revenue_per_user
FROM cohort_revenue cr
JOIN cohort_size cs
  ON cr.cohort_month = cs.cohort_month
WHERE cr.cohort_month >= '2023-01-01'
ORDER BY cr.cohort_month DESC, cr.months_since_cohort;
