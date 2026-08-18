WITH stg_paypay_bank AS (
  SELECT * FROM {{ ref('stg_paypay_bank__home_loan_schedule') }}
),

stg_orico_credit AS (
  SELECT * FROM {{ ref('stg_orico_credit__home_reform_loan_schedule') }}
),

paypay_bank AS (
  SELECT
    'paypay_bank' AS source_institution,
    'home_loan' AS loan_type,
    *
  FROM
    stg_paypay_bank
),

orico_credit AS (
  SELECT
    'orico_credit' AS source_institution,
    'home_reform_loan' AS loan_type,
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
    payment_date,
    source_institution,
    loan_type,
    payment_amount,
    principal_amount,
    interest_amount,
    extra_principal_amount,
    extra_interest_amount,
    annual_interest_rate,
    remaining_balance,
    ingested_at_utc
  FROM
    unioned
)

SELECT * FROM final
