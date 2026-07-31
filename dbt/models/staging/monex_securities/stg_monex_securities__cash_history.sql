WITH all_history AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

final AS (
  SELECT
    settlement_date,
    transaction_type,
    settlement_amount,
    ingested_at_utc
  FROM
    all_history
  WHERE
    product_name IS NULL
)

SELECT * FROM final
