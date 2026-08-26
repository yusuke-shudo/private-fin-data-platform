WITH source_data AS (
  SELECT * FROM {{ source('sbi_securities', 'tokutei_profit_loss_report_raw') }}
),

extracted_rows AS (
  SELECT
    IFF(line_number = 5, SPLIT(REPLACE(raw_text, '"'), ','), NULL) AS col_array,
    IFF(
      line_number = 5, TO_DATE(col_array[0]::VARCHAR, 'YYYY年MM月DD日'), NULL
    ) AS settlement_start_date,
    IFF(
      line_number = 5, TO_DATE(col_array[1]::VARCHAR, 'YYYY年MM月DD日'), NULL
    ) AS settlement_end_date,
    IFF(line_number = 8, raw_text::NUMBER, NULL) AS total_capital_gains_tax,
    IFF(line_number = 11, raw_text::NUMBER, NULL) AS total_realized_pl,
    IFF(line_number = 14, raw_text::NUMBER, NULL) AS total_dividend_withholding_tax,
    IFF(line_number = 17, raw_text::NUMBER, NULL) AS total_gross_dividend,
    file_path,
    ingested_at_utc
  FROM
    source_data
  WHERE
    line_number IN (5, 8, 11, 14, 17)
),

final AS (
  SELECT
    MAX(settlement_start_date) AS settlement_start_date,
    MAX(settlement_end_date) AS settlement_end_date,
    MAX(total_realized_pl) AS total_realized_pl,
    MAX(total_capital_gains_tax) AS total_capital_gains_tax,
    MAX(total_gross_dividend) AS total_gross_dividend,
    MAX(total_dividend_withholding_tax) AS total_dividend_withholding_tax,
    MAX(ingested_at_utc) AS ingested_at_utc
  FROM
    extracted_rows
  GROUP BY
    file_path
)

SELECT * FROM final
