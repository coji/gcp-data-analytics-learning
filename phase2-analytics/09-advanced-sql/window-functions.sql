-- Phase 2-09: ウィンドウ関数の演習
-- thelook_ecommerce データセットを使用

-- ============================================
-- 1. ROW_NUMBER(): 順位付け（重複なし）
-- ============================================

-- 流入元別の日次セッション数ランキング
SELECT
  DATE(created_at) AS event_date,
  traffic_source,
  COUNT(DISTINCT session_id) AS sessions,
  ROW_NUMBER() OVER (
    PARTITION BY DATE(created_at)
    ORDER BY COUNT(DISTINCT session_id) DESC
  ) AS daily_rank
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE created_at >= '2024-01-01'
  AND created_at < '2024-02-01'
GROUP BY event_date, traffic_source
ORDER BY event_date, daily_rank;


-- ============================================
-- 2. RANK(): 順位付け（同順位あり、次の順位は飛ぶ）
-- ============================================

-- ユーザー別の累計購入金額ランキング
WITH user_total_purchase AS (
  SELECT
    o.user_id,
    SUM(oi.sale_price) AS total_purchase_amount
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id
)

SELECT
  user_id,
  ROUND(total_purchase_amount, 2) AS total_purchase_amount,
  RANK() OVER (ORDER BY total_purchase_amount DESC) AS purchase_rank,
  ROW_NUMBER() OVER (ORDER BY total_purchase_amount DESC) AS row_num
FROM user_total_purchase
ORDER BY purchase_rank
LIMIT 20;


-- ============================================
-- 3. DENSE_RANK(): 順位付け（同順位あり、次の順位は連続）
-- ============================================

-- 日別の流入元別購入数ランキング
WITH daily_purchases AS (
  SELECT
    DATE(e.created_at) AS event_date,
    e.traffic_source,
    COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END) AS purchases
  FROM `bigquery-public-data.thelook_ecommerce.events` e
  WHERE e.created_at >= '2024-01-01'
    AND e.created_at < '2024-02-01'
  GROUP BY event_date, traffic_source
)

SELECT
  event_date,
  traffic_source,
  purchases,
  DENSE_RANK() OVER (PARTITION BY event_date ORDER BY purchases DESC) AS dense_rank,
  RANK() OVER (PARTITION BY event_date ORDER BY purchases DESC) AS rank_with_gaps
FROM daily_purchases
ORDER BY event_date, dense_rank;


-- ============================================
-- 4. LAG(): 前の行の値を取得
-- ============================================

-- 前日比の計算（日別注文数）
WITH daily_orders AS (
  SELECT
    DATE(created_at) AS order_date,
    COUNT(*) AS order_count,
    SUM(num_of_item) AS total_items
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
    AND created_at >= '2024-01-01'
    AND created_at < '2024-02-01'
  GROUP BY order_date
)

SELECT
  order_date,
  order_count,
  LAG(order_count) OVER (ORDER BY order_date) AS prev_day_orders,
  order_count - LAG(order_count) OVER (ORDER BY order_date) AS daily_change,
  ROUND(SAFE_DIVIDE(
    order_count - LAG(order_count) OVER (ORDER BY order_date),
    LAG(order_count) OVER (ORDER BY order_date)
  ) * 100, 2) AS growth_rate_percent
FROM daily_orders
ORDER BY order_date;


-- ============================================
-- 5. LEAD(): 次の行の値を取得
-- ============================================

-- ユーザーの次回購入までの日数を計算
WITH user_purchases AS (
  SELECT
    user_id,
    order_id,
    DATE(created_at) AS order_date,
    LEAD(DATE(created_at)) OVER (PARTITION BY user_id ORDER BY created_at) AS next_order_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
)

SELECT
  user_id,
  order_date,
  next_order_date,
  DATE_DIFF(next_order_date, order_date, DAY) AS days_to_next_purchase
FROM user_purchases
WHERE next_order_date IS NOT NULL
ORDER BY user_id, order_date
LIMIT 100;


-- ============================================
-- 6. FIRST_VALUE() / LAST_VALUE(): 最初/最後の値
-- ============================================

-- 各ユーザーの初回購入と最新購入の比較
WITH user_orders AS (
  SELECT
    o.user_id,
    DATE(o.created_at) AS order_date,
    oi.sale_price,
    FIRST_VALUE(DATE(o.created_at)) OVER (
      PARTITION BY o.user_id
      ORDER BY o.created_at
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_purchase_date,
    FIRST_VALUE(oi.sale_price) OVER (
      PARTITION BY o.user_id
      ORDER BY o.created_at
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_purchase_amount,
    LAST_VALUE(DATE(o.created_at)) OVER (
      PARTITION BY o.user_id
      ORDER BY o.created_at
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_purchase_date,
    LAST_VALUE(oi.sale_price) OVER (
      PARTITION BY o.user_id
      ORDER BY o.created_at
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_purchase_amount
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
)

SELECT DISTINCT
  user_id,
  first_purchase_date,
  ROUND(first_purchase_amount, 2) AS first_purchase_amount,
  last_purchase_date,
  ROUND(last_purchase_amount, 2) AS last_purchase_amount,
  DATE_DIFF(last_purchase_date, first_purchase_date, DAY) AS customer_lifetime_days
FROM user_orders
ORDER BY customer_lifetime_days DESC
LIMIT 100;


-- ============================================
-- 7. SUM() OVER(): 累積合計
-- ============================================

-- 日別の累積注文数と累積売上
WITH daily_stats AS (
  SELECT
    DATE(o.created_at) AS order_date,
    COUNT(DISTINCT o.order_id) AS daily_orders,
    SUM(oi.sale_price) AS daily_revenue
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
    AND o.created_at >= '2024-01-01'
    AND o.created_at < '2024-02-01'
  GROUP BY order_date
)

SELECT
  order_date,
  daily_orders,
  ROUND(daily_revenue, 2) AS daily_revenue,
  SUM(daily_orders) OVER (ORDER BY order_date) AS cumulative_orders,
  ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM daily_stats
ORDER BY order_date;


-- ============================================
-- 8. AVG() OVER(): 移動平均
-- ============================================

-- 7日移動平均の計算
WITH daily_orders AS (
  SELECT
    DATE(created_at) AS order_date,
    COUNT(*) AS order_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status = 'Complete'
    AND created_at >= '2024-01-01'
    AND created_at < '2024-02-01'
  GROUP BY order_date
)

SELECT
  order_date,
  order_count,
  ROUND(AVG(order_count) OVER (
    ORDER BY order_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ), 2) AS moving_avg_7d,
  ROUND(AVG(order_count) OVER (
    ORDER BY order_date
    ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
  ), 2) AS moving_avg_14d
FROM daily_orders
ORDER BY order_date;


-- ============================================
-- 9. NTILE(): パーセンタイルグループに分割
-- ============================================

-- ユーザーを購入金額で4分位に分割（RFM分析の応用）
WITH user_segments AS (
  SELECT
    o.user_id,
    SUM(oi.sale_price) AS total_purchase,
    COUNT(DISTINCT o.order_id) AS order_count,
    MAX(DATE(o.created_at)) AS last_purchase_date,
    NTILE(4) OVER (ORDER BY SUM(oi.sale_price) DESC) AS revenue_quartile
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status = 'Complete'
  GROUP BY o.user_id
)

SELECT
  revenue_quartile,
  COUNT(DISTINCT user_id) AS user_count,
  ROUND(AVG(total_purchase), 2) AS avg_total_purchase,
  ROUND(MIN(total_purchase), 2) AS min_purchase,
  ROUND(MAX(total_purchase), 2) AS max_purchase,
  ROUND(AVG(order_count), 2) AS avg_order_count
FROM user_segments
GROUP BY revenue_quartile
ORDER BY revenue_quartile;
