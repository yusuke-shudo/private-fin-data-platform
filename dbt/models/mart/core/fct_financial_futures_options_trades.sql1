{{ config(
    materialized='table'
) }}

WITH int_data AS (
  SELECT * FROM {{ ref('int_unified_financial_securities__futures_options_trades') }}
)

SELECT * FROM int_data
