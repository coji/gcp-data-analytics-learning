-- Phase 2-09: LTV計算クエリ
-- thelook_ecommerce データセットを使用

-- ============================================
-- 1. ユーザーごとのLTV計算（7日、30日、60日、全期間）
-- ============================================

WITH user_first_order AS (
  -- 各ユーザーの初回注文日を取得
  SELECT
    user_id,
    MIN(created_at) AS first_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

user_revenue AS (
  -- 各注文と初回注文日からの経過日数を計算
  SELECT
    o.user_id,
    fo.first_order_date,
    DATE(o.created_at) AS order_date,
    SUM(oi.sale_price) AS order_revenue,
    DATE_DIFF(DATE(o.created_at), DATE(fo.first_order_date), DAY) AS days_since_first
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN user_first_order fo
    ON o.user_id = fo.user_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id, fo.first_order_date, order_date
),

user_ltv AS (
  -- 期間別LTVを計算
  SELECT
    user_id,
    first_order_date,

    -- 7日LTV
    SUM(CASE WHEN days_since_first <= 7 THEN order_revenue ELSE 0 END) AS ltv_7d,

    -- 30日LTV
    SUM(CASE WHEN days_since_first <= 30 THEN order_revenue ELSE 0 END) AS ltv_30d,

    -- 60日LTV
    SUM(CASE WHEN days_since_first <= 60 THEN order_revenue ELSE 0 END) AS ltv_60d,

    -- 90日LTV
    SUM(CASE WHEN days_since_first <= 90 THEN order_revenue ELSE 0 END) AS ltv_90d,

    -- 全期間LTV
    SUM(order_revenue) AS ltv_total,

    -- 注文回数
    COUNT(DISTINCT order_date) AS total_orders

  FROM user_revenue
  GROUP BY user_id, first_order_date
)

SELECT *
FROM user_ltv
ORDER BY ltv_total DESC
LIMIT 100;


-- ============================================
-- 2. 流入元別の平均LTV
-- ============================================

WITH user_first_event AS (
  -- 各ユーザーの初回イベントから流入元を取得
  SELECT
    user_id,
    MIN(created_at) AS first_event_date,
    ARRAY_AGG(traffic_source ORDER BY created_at LIMIT 1)[OFFSET(0)] AS first_traffic_source
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE user_id IS NOT NULL
  GROUP BY user_id
),

user_first_order AS (
  SELECT
    user_id,
    MIN(created_at) AS first_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

user_revenue AS (
  SELECT
    o.user_id,
    fo.first_order_date,
    SUM(oi.sale_price) AS order_revenue,
    DATE_DIFF(DATE(o.created_at), DATE(fo.first_order_date), DAY) AS days_since_first
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN user_first_order fo
    ON o.user_id = fo.user_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id, fo.first_order_date, o.created_at
),

user_ltv AS (
  SELECT
    user_id,
    SUM(CASE WHEN days_since_first <= 30 THEN order_revenue ELSE 0 END) AS ltv_30d,
    SUM(CASE WHEN days_since_first <= 60 THEN order_revenue ELSE 0 END) AS ltv_60d,
    SUM(order_revenue) AS ltv_total
  FROM user_revenue
  GROUP BY user_id
)

SELECT
  ufe.first_traffic_source AS traffic_source,
  COUNT(DISTINCT ul.user_id) AS user_count,
  ROUND(AVG(ul.ltv_30d), 2) AS avg_ltv_30d,
  ROUND(AVG(ul.ltv_60d), 2) AS avg_ltv_60d,
  ROUND(AVG(ul.ltv_total), 2) AS avg_ltv_total,
  ROUND(SUM(ul.ltv_total), 2) AS total_revenue
FROM user_ltv ul
JOIN user_first_event ufe
  ON ul.user_id = ufe.user_id
GROUP BY traffic_source
ORDER BY total_revenue DESC;


-- ============================================
-- 3. コホート別のLTV推移
-- ============================================

WITH cohort_base AS (
  -- 月次コホート定義
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
    cb.user_id,
    DATE_TRUNC(o.created_at, MONTH) AS activity_month,
    DATE_DIFF(DATE_TRUNC(o.created_at, MONTH), cb.cohort_month, MONTH) AS months_since_cohort,
    SUM(oi.sale_price) AS revenue
  FROM cohort_base cb
  JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON cb.user_id = o.user_id
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
  GROUP BY cb.cohort_month, cb.user_id, activity_month
)

SELECT
  cohort_month,
  months_since_cohort,
  COUNT(DISTINCT user_id) AS active_users,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(AVG(revenue), 2) AS avg_revenue_per_user
FROM cohort_revenue
WHERE cohort_month >= '2023-01-01'  -- 直近のコホートのみ分析
GROUP BY cohort_month, months_since_cohort
ORDER BY cohort_month DESC, months_since_cohort;


-- ============================================
-- 4. リピート購入率とLTVの関係
-- ============================================

WITH user_first_order AS (
  SELECT
    user_id,
    MIN(created_at) AS first_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
  GROUP BY user_id
),

user_metrics AS (
  SELECT
    o.user_id,
    fo.first_order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.sale_price) AS ltv,
    -- 2回目購入までの日数
    MIN(CASE
      WHEN DATE(o.created_at) > DATE(fo.first_order_date)
      THEN DATE_DIFF(DATE(o.created_at), DATE(fo.first_order_date), DAY)
    END) AS days_to_second_purchase
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN user_first_order fo
    ON o.user_id = fo.user_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id, fo.first_order_date
)

SELECT
  CASE
    WHEN total_orders = 1 THEN '1回購入'
    WHEN total_orders = 2 THEN '2回購入'
    WHEN total_orders BETWEEN 3 AND 5 THEN '3-5回購入'
    WHEN total_orders >= 6 THEN '6回以上購入'
  END AS purchase_frequency,
  COUNT(DISTINCT user_id) AS user_count,
  ROUND(AVG(ltv), 2) AS avg_ltv,
  ROUND(AVG(days_to_second_purchase), 1) AS avg_days_to_second_purchase
FROM user_metrics
GROUP BY purchase_frequency
ORDER BY
  CASE purchase_frequency
    WHEN '1回購入' THEN 1
    WHEN '2回購入' THEN 2
    WHEN '3-5回購入' THEN 3
    WHEN '6回以上購入' THEN 4
  END;
