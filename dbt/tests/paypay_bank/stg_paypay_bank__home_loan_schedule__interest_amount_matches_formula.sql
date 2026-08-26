WITH stg_data AS (
  SELECT * FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
),

ordered AS (
  SELECT
    payment_date,
    annual_interest_rate,
    interest_amount,
    remaining_balance,
    LAG(remaining_balance)
      OVER (ORDER BY payment_date) AS prev_remaining_balance
  FROM stg_data
),

validated AS (
  SELECT
    payment_date,
    annual_interest_rate,
    prev_remaining_balance,
    interest_amount,
    FLOOR(
      prev_remaining_balance * (annual_interest_rate / 100) / 12
    ) AS expected_interest_amount
  FROM
    ordered
  WHERE
    prev_remaining_balance IS NOT NULL
),

invalid_balance_records AS (
  SELECT
    payment_date,
    annual_interest_rate,
    prev_remaining_balance,
    interest_amount,
    expected_interest_amount
  FROM
    validated
  WHERE
    interest_amount <> expected_interest_amount
)

SELECT * FROM invalid_balance_records
