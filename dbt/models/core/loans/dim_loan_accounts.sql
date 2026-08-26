{{ config(
  materialized='table'
) }}

WITH int_data AS (
  SELECT * FROM {{ ref('loan_accounts') }}
),

final AS (
  SELECT
    loan_account_id,
    source_institution,
    loan_type,
    account_display_name
  FROM
    int_data
)

SELECT * FROM final
