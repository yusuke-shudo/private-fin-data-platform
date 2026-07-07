WITH source_data AS (
  SELECT * FROM {{ source('paypay_bank', 'home_loan_schedule_raw') }}
),

data1 AS (
  SELECT
    SPLIT(REPLACE(raw_text, '"'), ',') AS col_array,
    ingest_at_utc
  FROM
    source_data
  WHERE
    line_number > 1
),

data2 AS (
  SELECT
    TO_DATE(col_array[0]::VARCHAR, 'YYYY/MM/DD') AS payment_date,
    col_array[1]::NUMBER AS payment_amount,
    col_array[2]::NUMBER AS principal_amount,
    col_array[3]::NUMBER AS interest_amount,
    NULLIF(col_array[4]::VARCHAR, '-')::NUMBER AS extra_principal_amount,
    NULLIF(col_array[5]::VARCHAR, '-')::NUMBER AS extra_interest_amount,
    col_array[6]::NUMBER(4, 2) AS annual_interest_rate,
    col_array[7]::NUMBER AS remaining_balance,
    ingest_at_utc
  FROM
    data1
)

SELECT * FROM data2;
