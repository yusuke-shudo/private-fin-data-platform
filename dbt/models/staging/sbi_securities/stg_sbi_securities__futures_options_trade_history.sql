WITH source_data AS (
  SELECT * FROM {{ source('sbi_securities', 'futures_options_trade_history_raw') }}
),

csv_split AS (
  SELECT
    PARSE_JSON('[' || raw_text || ']') AS col_array,
    line_number,
    ingested_at_utc
  FROM
    source_data
  WHERE
    line_number > 6

),

final AS (
  SELECT
    col_array[3]::VARCHAR AS contract_name,
    TO_DATE(col_array[18]::VARCHAR, 'YYYY/MM/DD') AS sq_date,
    col_array[2]::VARCHAR AS market_name,
    TO_TIMESTAMP_NTZ(col_array[1]::VARCHAR, 'YYYY/MM/DD HH24:MI') AS executed_at_jst,
    TO_DATE(col_array[10]::VARCHAR, 'YYYY/MM/DD') AS trade_date,
    TO_DATE(NULLIF(col_array[12]::VARCHAR, '--'), 'YYYY/MM/DD') AS settlement_date,
    col_array[4]::VARCHAR AS transaction_type,
    col_array[5]::NUMBER(18, 4) AS execution_price,
    col_array[6]::NUMBER AS execution_quantity,
    col_array[7]::NUMBER AS commission_amount,
    col_array[8]::NUMBER AS tax_amount,
    col_array[9]::NUMBER AS execution_amount,
    NULLIF(col_array[11]::VARCHAR, '--')::NUMBER AS settlement_amount,
    TO_DATE(NULLIF(col_array[13]::VARCHAR, '--'), 'YYYY/MM/DD') AS position_open_date,
    NULLIF(col_array[14]::VARCHAR, '--')::NUMBER(18, 4) AS position_open_price,
    NULLIF(col_array[15]::VARCHAR, '--')::NUMBER AS position_open_commission_amount,
    NULLIF(col_array[16]::VARCHAR, '--')::NUMBER AS position_open_tax_amount,
    NULLIF(col_array[17]::VARCHAR, '--')::NUMBER AS realized_profit_loss,
    ingested_at_utc
  FROM
    csv_split
)

SELECT * FROM final
