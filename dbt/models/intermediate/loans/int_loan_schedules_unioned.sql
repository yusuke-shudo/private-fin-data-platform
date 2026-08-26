WITH stg_paypay_bank AS (
  SELECT * FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
),

stg_orico_credit AS (
  SELECT * FROM {{ ref('stg_orico_credit__home_reform_loan_schedule') }}
),

seed_loan_accounts AS (
  SELECT * FROM {{ ref('loan_accounts') }}
),

paypay_bank AS (
  SELECT
    'paypay_bank_home_loan_1' AS source_dataset_key,
    *
  FROM
    stg_paypay_bank
),

orico_credit AS (
  SELECT
    'orico_credit_home_reform_loan_1' AS source_dataset_key,
    *
  FROM
    stg_orico_credit
),

unioned AS (
  SELECT * FROM paypay_bank
  UNION ALL
  SELECT * FROM orico_credit
),

final AS (
  SELECT
    seed_loan_accounts.loan_account_id,
    seed_loan_accounts.source_institution,
    seed_loan_accounts.loan_type,
    unioned.payment_date,
    unioned.payment_amount,
    unioned.principal_amount,
    unioned.interest_amount,
    unioned.extra_principal_amount,
    unioned.extra_interest_amount,
    unioned.annual_interest_rate,
    unioned.remaining_balance,
    unioned.ingested_at_utc
  FROM
    unioned
  LEFT JOIN
    seed_loan_accounts
    ON
      unioned.source_dataset_key = seed_loan_accounts.source_dataset_key
)

SELECT * FROM final
