{{ config(
  materialized='table'
) }}

WITH int_data AS (
  SELECT * FROM {{ ref('int_securities_futures_options_trades_unioned') }}
),

final AS (
  SELECT
    *
  FROM
    int_data
)

SELECT * FROM final
