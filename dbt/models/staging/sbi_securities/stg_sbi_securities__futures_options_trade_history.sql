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
    TO_TIMESTAMP_NTZ(col_array[1]::VARCHAR, 'YYYY/MM/DD HH24:MI') AS executed_at_jst,
    TO_DATE(col_array[10]::VARCHAR, 'YYYY/MM/DD') AS trade_date,
    TO_DATE(NULLIF(col_array[12]::VARCHAR, '--'), 'YYYY/MM/DD') AS settlement_date,
    col_array[3]::VARCHAR AS contract_name,
    CASE
      WHEN contract_name LIKE 'マイクロ225%' THEN 'Nikkei 225 micro'
      WHEN contract_name LIKE 'ミニ225%' THEN 'Nikkei 225 mini'
      WHEN contract_name LIKE '225%' THEN 'Nikkei 225'
      ELSE contract_name
    END AS product_name,
    CASE
      WHEN ENDSWITH(product_name, 'micro') THEN 10
      WHEN ENDSWITH(product_name, 'mini') THEN 100
      ELSE 1000
    END AS contract_lot_size,
    CASE
      WHEN contract_name LIKE '%先物%' THEN 'Futures'
      WHEN contract_name LIKE '%ＯＰ%' THEN 'Options'
    END AS product_type,
    TO_DATE(col_array[18]::VARCHAR, 'YYYY/MM/DD') AS sq_date,
    CASE
      WHEN contract_name LIKE '%コール%' THEN 'CALL'
      WHEN contract_name LIKE '%プット%' THEN 'PUT'
    END AS option_type,
    IFF(
      product_type = 'Options',
      TO_NUMBER(REGEXP_SUBSTR(contract_name, '([0-9\,]+)円$', 1, 1, 'e', 1), '999,999'),
      NULL
    ) AS strike_price,
    col_array[4]::VARCHAR AS transaction_type,
    CASE
      WHEN transaction_type IN (
        '新規買', '決済買', '決済買(割当)', '新規売(消滅)'
      ) THEN 'BUY'
      WHEN transaction_type IN (
        '新規売', '決済売', '決済売(清算)', '決済売(行使)', '新規買(放棄)'
      ) THEN 'SELL'
    END AS trade_side,
    CASE
      WHEN transaction_type IN ('新規買', '新規売') THEN 'OPEN'
      WHEN transaction_type IN (
        '決済買', '決済売', '決済買(割当)', '決済売(清算)', '決済売(行使)', '新規売(消滅)', '新規買(放棄)'
      ) THEN 'CLOSE'
    END AS trade_action,
    CASE
      WHEN transaction_type IN ('新規買', '新規売', '決済買', '決済売') THEN 'MANUAL'
      WHEN transaction_type = '決済売(清算)' THEN 'SQ_SETTLEMENT'
      WHEN transaction_type = '決済売(行使)' THEN 'SQ_EXERCISE'
      WHEN transaction_type = '決済買(割当)' THEN 'SQ_ASSIGNMENT'
      WHEN transaction_type IN ('新規売(消滅)', '新規買(放棄)') THEN 'SQ_EXPIRY'
    END AS execution_method,
    col_array[2]::VARCHAR AS market_name,
    col_array[5]::NUMBER(18, 4) AS unit_price,
    col_array[6]::NUMBER AS quantity,
    col_array[9]::NUMBER AS execution_amount,
    col_array[7]::NUMBER AS commission_amount,
    col_array[8]::NUMBER AS tax_amount,
    NULLIF(col_array[11]::VARCHAR, '--')::NUMBER AS settlement_amount,
    TO_DATE(NULLIF(col_array[13]::VARCHAR, '--'), 'YYYY/MM/DD') AS position_open_date,
    NULLIF(col_array[14]::VARCHAR, '--')::NUMBER(18, 4) AS position_open_price,
    IFF(
      trade_action = 'CLOSE',
      FLOOR(position_open_price * quantity * contract_lot_size),
      NULL
    ) AS position_open_execution_amount,
    NULLIF(col_array[15]::VARCHAR, '--')::NUMBER AS position_open_commission_amount,
    NULLIF(col_array[16]::VARCHAR, '--')::NUMBER AS position_open_tax_amount,
    IFF(
      product_type = 'Options' AND trade_action = 'CLOSE',
      FLOOR(position_open_price * quantity * contract_lot_size) * IFF(trade_side = 'SELL', -1, 1) - (position_open_commission_amount + position_open_tax_amount),
      NULL
    ) AS position_open_settlement_amount,
    NULLIF(col_array[17]::VARCHAR, '--')::NUMBER AS realized_profit_loss,
    ingested_at_utc
  FROM
    csv_split
)

SELECT * FROM final
