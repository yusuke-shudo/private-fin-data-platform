WITH source_data AS (
  SELECT * FROM {{ source('sbi_securities', 'futures_options_trade_history_raw') }}
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
    line_number > 6
),

final AS (
  SELECT
    file_path,
    line_number,
    col_array[3]::VARCHAR AS contract_name,
    -- Categorizing: Extract standardized product information
    CASE
      WHEN col_array[3]::VARCHAR LIKE 'マイクロ225%' THEN 'Nikkei 225 micro'
      WHEN col_array[3]::VARCHAR LIKE 'ミニ225%' THEN 'Nikkei 225 mini'
      WHEN col_array[3]::VARCHAR LIKE '225%' THEN 'Nikkei 225'
      ELSE col_array[3]::VARCHAR
    END AS product_name,
    CASE
      WHEN col_array[3]::VARCHAR LIKE '%先物%' THEN 'Futures'
      WHEN col_array[3]::VARCHAR LIKE '%ＯＰ%' THEN 'Options'
      ELSE NULL
    END AS product_type,
    '20' || 
    SUBSTR(col_array[3]::VARCHAR, POSITION('年' IN col_array[3]::VARCHAR) - 2, 2) || '-' ||
    SUBSTR(col_array[3]::VARCHAR, POSITION('月' IN col_array[3]::VARCHAR) - 2, 2) AS contract_month,
    CASE
      WHEN col_array[3]::VARCHAR LIKE '%コール%' THEN 'CALL'
      WHEN col_array[3]::VARCHAR LIKE '%プット%' THEN 'PUT'
      ELSE NULL
    END AS option_type,
    CASE
      WHEN col_array[3]::VARCHAR LIKE '%円' THEN 
        REGEXP_REPLACE(REGEXP_SUBSTR(col_array[3]::VARCHAR, '[0-9,]+円$'), '[,円]', '')
      ELSE NULL
    END AS strike_price,
    TO_DATE(col_array[18]::VARCHAR, 'YYYY/MM/DD') AS sq_date,
    col_array[2]::VARCHAR AS market_name,
    TO_TIMESTAMP_NTZ(col_array[1]::VARCHAR, 'YYYY/MM/DD HH24:MI') AS executed_at_jst,
    TO_DATE(col_array[10]::VARCHAR, 'YYYY/MM/DD') AS trade_date,
    TO_DATE(NULLIF(col_array[12]::VARCHAR, '--'), 'YYYY/MM/DD') AS settlement_date,
    col_array[4]::VARCHAR AS transaction_type,
    -- Categorizing: Decompose transaction_type into standardized components
    CASE
      WHEN col_array[4]::VARCHAR = '新規買' THEN 'BUY'
      WHEN col_array[4]::VARCHAR = '新規売' THEN 'SELL'
      WHEN col_array[4]::VARCHAR = '新規買(放棄)' THEN 'SELL'
      WHEN col_array[4]::VARCHAR = '新規売(消滅)' THEN 'BUY'
      WHEN col_array[4]::VARCHAR IN ('決済買', '決済買(割当)') THEN 'BUY'
      WHEN col_array[4]::VARCHAR IN ('決済売', '決済売(清算)', '決済売(行使)') THEN 'SELL'
      ELSE NULL
    END AS trade_side,
    CASE
      WHEN col_array[4]::VARCHAR IN ('新規買', '新規売') THEN 'OPEN'
      WHEN col_array[4]::VARCHAR IN ('新規買(放棄)', '新規売(消滅)', '決済買', '決済買(割当)', '決済売', '決済売(清算)', '決済売(行使)') THEN 'CLOSE'
      ELSE NULL
    END AS trade_action,
    CASE
      WHEN col_array[4]::VARCHAR IN ('新規買', '新規売', '決済買', '決済売') THEN 'MANUAL'
      WHEN col_array[4]::VARCHAR = '決済売(清算)' THEN 'SQ_SETTLEMENT'
      WHEN col_array[4]::VARCHAR = '決済売(行使)' THEN 'SQ_EXERCISE'
      WHEN col_array[4]::VARCHAR = '決済買(割当)' THEN 'SQ_ASSIGNMENT'
      WHEN col_array[4]::VARCHAR IN ('新規買(放棄)', '新規売(消滅)') THEN 'SQ_EXPIRY'
      ELSE NULL
    END AS execution_method,
    col_array[5]::NUMBER(18, 4) AS unit_price,
    col_array[6]::NUMBER AS quantity,
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
