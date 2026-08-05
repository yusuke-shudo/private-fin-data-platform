WITH ordered AS (
  SELECT
    payment_date,
    annual_interest_rate,
    interest_amount,
    remaining_balance,
    LAG(remaining_balance) OVER (ORDER BY payment_date) AS prev_remaining_balance
  FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
),

validated AS (
  SELECT
    payment_date,
    annual_interest_rate,
    prev_remaining_balance,
    interest_amount,
    FLOOR(prev_remaining_balance * (annual_interest_rate / 100) / 12) AS expected_interest_amount
  FROM ordered
  WHERE prev_remaining_balance IS NOT NULL
)

SELECT
  payment_date,
  annual_interest_rate,
  prev_remaining_balance,
  interest_amount,
  expected_interest_amount
FROM validated
WHERE interest_amount <> expected_interest_amount
