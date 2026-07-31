WITH all_history AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

final AS (
  SELECT
    trade_date,
    settlement_date,
    product_name,
    transaction_type,
    ticket_code,
    security_name,
    quantity,
    unit_price,
    settlement_amount,
    commission_amount,
    tax_amount,
    ingested_at_utc
  FROM
    all_history
  WHERE
    product_name IN ('先物', 'オプション')
)

SELECT * FROM final
