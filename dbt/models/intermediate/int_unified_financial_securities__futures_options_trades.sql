WITH sbi_source AS (
  SELECT * FROM {{ ref('stg_sbi_securities__futures_options_trade_history') }}
),

monex_source AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

sbi_mapped AS (
  SELECT
    'SBI_SECURITIES-' || unique_execution_key AS unique_trade_key,
    'SBI Securities' AS institution_name,
    execution_id,
    execution_sub_id,
    trade_date,
    settlement_date,
    market_name,
    security_name,
    transaction_type,
    execution_price,
    execution_quantity,
    commission_amount,
    tax_amount,
    execution_amount,
    settlement_amount,
    realized_profit_loss,
    ingested_at_utc
  FROM
    sbi_source
),

monex_mapped AS (
  SELECT
    'MONEX_SECURITIES-' || unique_execution_key AS unique_trade_key,
    'MONEX Securities' AS institution_name,
    execution_id,
    execution_sub_id,
    trade_date,
    settlement_date,
    NULL AS market_name,
    security_name,
    transaction_type,
    unit_price AS execution_price,
    quantity AS execution_quantity,
    commission_amount,
    tax_amount,
    COALESCE(open_settlement_amount, unit_price * quantity) AS execution_amount, 
    settlement_amount,
    dividend_and_distribution_amount AS realized_profit_loss,
    ingested_at_utc
  FROM
    monex_source
  WHERE
    product_name IN ('先物', 'オプション')
),

unified_trades AS (
  SELECT * FROM sbi_mapped
  UNION ALL
  SELECT * FROM monex_mapped
),

final AS (
  SELECT
    unique_trade_key,
    institution_name,
    execution_id,
    execution_sub_id,
    trade_date,
    settlement_date,
    
    -- 時間軸の抽出
    YEAR(trade_date) AS trade_year,
    DATE_TRUNC('month', trade_date) AS trade_month,
    
    market_name,
    security_name,
    transaction_type,
    
    -- 売買方向の標準化
    CASE 
      WHEN transaction_type IN ('新規買', '買建', '決済買') THEN 'BUY'
      WHEN transaction_type IN ('新規売', '売建', '決済売', '決済売(清算)', '転売') THEN 'SELL'
      WHEN transaction_type LIKE '%放棄%' THEN 'ABANDONMENT'
      ELSE 'OTHER'
    END AS trade_direction,
    
    execution_price,
    execution_quantity,
    execution_amount,
    commission_amount,
    tax_amount,
    
    -- 計算カラム
    commission_amount + tax_amount AS total_fees_amount,
    settlement_amount,
    realized_profit_loss,
    ingested_at_utc
  FROM
    unified_trades
)

SELECT * FROM final
