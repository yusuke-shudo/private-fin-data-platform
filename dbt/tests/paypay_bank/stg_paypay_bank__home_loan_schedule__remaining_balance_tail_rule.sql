WITH stg_data AS (
  SELECT * FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
),

ordered AS (
  SELECT
    payment_date,
    remaining_balance,
    ROW_NUMBER() OVER (ORDER BY payment_date DESC) AS row_num
  FROM
    stg_data
),

invalid_balance_records AS (
  SELECT
    payment_date,
    remaining_balance,
    row_num
  FROM
    ordered
  WHERE
    (row_num = 1 AND remaining_balance <> 0)     -- Final row should have remaining balance of 0
    OR (row_num > 1 AND remaining_balance <= 0)  -- Rows before final should have positive remaining balance
)

SELECT * FROM invalid_balance_records
