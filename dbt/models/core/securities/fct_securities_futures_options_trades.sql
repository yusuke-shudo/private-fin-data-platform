WITH intermediate AS (
  SELECT * FROM {{ ref('int_securities_futures_options_trades_unioned') }}
)

SELECT
  trade_date,
  settlement_date,
  contract_name,
  product_name,
  product_type,
  contract_month,
  option_type,
  strike_price,
  transaction_type,
  trade_side,
  trade_action,
  execution_method,
  source_institution,
  seq_no,
  quantity,
  unit_price,
  commission_amount,
  tax_amount,
  settlement_amount,
  ingested_at_utc
FROM intermediate
