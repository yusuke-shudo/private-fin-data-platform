WITH all_history AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

final AS (
  SELECT
    file_path,
    line_number,
    trade_date,
    settlement_date,
    transaction_type,
    settlement_amount,
    ingested_at_utc
  FROM
    all_history
  WHERE
    security_type IS NULL
)

SELECT * FROM final
