{{ config(
  materialized='table'
) }}

WITH int_data AS (
  SELECT * FROM {{ ref('int_securities_futures_options_trades_unioned') }}
),

final AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key([
        'trade_date', 'settlement_date', 'product_name', 'product_type',
        'sq_week', 'option_type', 'strike_price', 'trade_action',
        'trade_side', 'execution_method', 'source_institution', 'seq_no'
    ]) }} AS trade_surrogate_key,
    *
  FROM
    int_data
)

SELECT * FROM final
