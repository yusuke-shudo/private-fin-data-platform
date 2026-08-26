WITH source_data AS (
  SELECT * FROM {{ source('monex_securities', 'all_trade_and_cash_history_raw') }}
),

csv_split AS (
  SELECT
    file_path,
    line_number,
    PARSE_JSON('[' || raw_text || ']') AS col_array,
    ingested_at_utc
  FROM
    source_data
  WHERE
    line_number > 2
),

final AS (
  SELECT
    file_path,
    line_number,
    TO_DATE(col_array[0]::VARCHAR, 'YYYY/MM/DD') AS trade_date,
    TO_DATE(col_array[1]::VARCHAR, 'YYYY/MM/DD') AS settlement_date,
    NULLIF(TRIM(col_array[2]::VARCHAR), '') AS account_type,
    NULLIF(TRIM(col_array[3]::VARCHAR), '') AS security_type,
    TRIM(col_array[4]::VARCHAR) AS transaction_type,
    NULLIF(TRIM(col_array[5]::VARCHAR), '') AS ticker_code,
    NULLIF(TRIM(col_array[6]::VARCHAR), '') AS security_name,
    REPLACE(col_array[7]::VARCHAR, ',', '')::NUMBER AS quantity,
    REPLACE(col_array[8]::VARCHAR, ',', '')::NUMBER(18, 4) AS unit_price,
    ABS(REPLACE(col_array[9]::VARCHAR, ',', '')::NUMBER) AS commission_amount,
    ABS(REPLACE(col_array[10]::VARCHAR, ',', '')::NUMBER) AS tax_amount,
    REPLACE(col_array[11]::VARCHAR, ',', '')::NUMBER AS dividend_and_distribution_amount,
    NULLIF(REPLACE(col_array[12]::VARCHAR, ',', ''), '')::NUMBER AS settlement_amount,
    TRY_TO_DATE(col_array[13]::VARCHAR, 'YYYY/MM/DD') AS open_trade_date,
    NULLIF(REPLACE(col_array[14]::VARCHAR, ',', ''), '')::NUMBER AS open_unit_price,
    NULLIF(REPLACE(col_array[15]::VARCHAR, ',', ''), '')::NUMBER AS open_settlement_amount,
    ABS(NULLIF(REPLACE(col_array[16]::VARCHAR, ',', ''), '')::NUMBER) AS open_commission_amount,
    ABS(NULLIF(REPLACE(col_array[17]::VARCHAR, ',', ''), '')::NUMBER) AS open_commission_tax_amount,
    NULLIF(REPLACE(col_array[18]::VARCHAR, ',', ''), '')::NUMBER AS administrative_fee,
    NULLIF(REPLACE(col_array[19]::VARCHAR, ',', ''), '')::NUMBER AS stock_transfer_fee,
    NULLIF(REPLACE(col_array[20]::VARCHAR, ',', ''), '')::NUMBER AS long_premium_amount,
    NULLIF(REPLACE(col_array[21]::VARCHAR, ',', ''), '')::NUMBER AS short_premium_amount,
    NULLIF(REPLACE(col_array[22]::VARCHAR, ',', ''), '')::NUMBER AS stock_lending_fee,
    NULLIF(REPLACE(col_array[23]::VARCHAR, ',', ''), '')::NUMBER AS miscellaneous_expenses,
    NULLIF(TRIM(col_array[24]::VARCHAR), '') AS remarks,
    ingested_at_utc
  FROM
    csv_split
)

SELECT * FROM final
