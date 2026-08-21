{{ config(
  materialized='table'
) }}

WITH int_data AS (
  SELECT * FROM {{ ref('int_loan_schedules_unioned') }}
),

final AS (
  SELECT
    *
  FROM
    int_data
)

SELECT * FROM final
