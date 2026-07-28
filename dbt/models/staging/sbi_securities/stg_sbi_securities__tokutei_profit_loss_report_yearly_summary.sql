WITH source_data AS (
  SELECT * FROM {{ source('sbi_securities', 'sbi_tokutei_profit_loss_report_raw') }}
),

csv_split AS (
  SELECT
    SPLIT(REPLACE(raw_text, '"'), ',') AS col_array,
    ingested_at_utc
  FROM
    source_data
  WHERE
    line_number = 5
),

summary1 AS (
  SELECT
    TO_DATE(col_array[0]::VARCHAR, 'YYYY/MM/DD') AS settlement_start_date,
    TO_DATE(col_array[1]::VARCHAR, 'YYYY/MM/DD') AS settlement_end_date,
    ingested_at_utc
  FROM
    csv_split
),

summary2 AS (
  SELECT
    raw_text::NUMBER AS total_capital_gains_tax
  FROM
    source_data
  WHERE
    line_number = 8
),

summary3 AS (
  SELECT
    raw_text::NUMBER AS total_realized_pl
  FROM
    source_data
  WHERE
    line_number = 11
),

summary4 AS (
  SELECT
    raw_text::NUMBER AS total_dividend_withholding_tax
  FROM
    source_data
  WHERE
    line_number = 14
),

summary5 AS (
  SELECT
    raw_text::NUMBER AS total_gross_dividend
  FROM
    source_data
  WHERE
    line_number = 17
),

final AS (
  SELECT
    summary1.*,
    summary2.*,
    summary3.*,
    summary4.*,
    summary5.*
  FROM
    summary1
  CROSS JOIN
    summary2
  CROSS JOIN
    summary3
  CROSS JOIN
    summary4
  CROSS JOIN
    summary5
)

SELECT * FROM final
