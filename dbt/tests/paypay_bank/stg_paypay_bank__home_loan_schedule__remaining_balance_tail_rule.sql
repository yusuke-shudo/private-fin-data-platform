WITH ordered AS (
  SELECT
    payment_date,
    remaining_balance,
    ROW_NUMBER() OVER (ORDER BY payment_date DESC) AS rn_desc
  FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
)

SELECT
  payment_date,
  remaining_balance,
  rn_desc
FROM ordered
WHERE
  (rn_desc = 1 AND remaining_balance <> 0)
  OR (rn_desc > 1 AND remaining_balance <= 0)
