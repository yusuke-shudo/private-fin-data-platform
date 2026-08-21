WITH all_history AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

final AS (
  SELECT
    file_path,
    line_number,
    trade_date,
    settlement_date,
    security_type,
    transaction_type,
    security_name AS contract_name,
    -- Categorizing: Extract standardized product information
    CASE
      WHEN security_name LIKE '日経225マイクロ%' THEN 'Nikkei 225 micro'
      WHEN security_name LIKE '日経225ミニ%' THEN 'Nikkei 225 mini'
      WHEN security_name LIKE '日経225%' THEN 'Nikkei 225'
      ELSE security_name
    END AS product_name,
    CASE
      WHEN security_type = '先物' THEN 'Futures'
      WHEN security_type = 'オプション' THEN 'Options'
      ELSE NULL
    END AS product_type,
    '20' || SUBSTR(security_name, POSITION('/' IN security_name) - 2, 2) || '-' ||
    SUBSTR(security_name, POSITION('/' IN security_name) + 1, 2) AS contract_month,
    CASE
      WHEN security_name LIKE '%ｺｰﾙ%' THEN 'CALL'
      WHEN security_name LIKE '%ﾌﾟｯﾄ%' THEN 'PUT'
      ELSE NULL
    END AS option_type,
    CASE
      WHEN security_type = 'オプション' THEN
        TRIM(REGEXP_SUBSTR(security_name, '[0-9]+', 1, REGEXP_COUNT(security_name, '[0-9]+')))
      ELSE NULL
    END AS strike_price,
    -- Categorizing: Decompose transaction_type into standardized components
    CASE
      WHEN transaction_type IN ('買建', '買戻') THEN 'BUY'
      WHEN transaction_type IN ('売建', '転売', '決済売', 'ＳＱ決済売') THEN 'SELL'
      WHEN transaction_type = '権利割当' THEN 'BUY'
      WHEN transaction_type = '権利放棄' THEN 'SELL'
      ELSE NULL
    END AS trade_side,
    CASE
      WHEN transaction_type IN ('買建', '売建') THEN 'OPEN'
      WHEN transaction_type IN ('買戻', '転売', '決済売', 'ＳＱ決済売') THEN 'CLOSE'
      WHEN transaction_type IN ('権利割当', '権利放棄') THEN 'CLOSE'
      ELSE NULL
    END AS trade_action,
    CASE
      WHEN transaction_type IN ('買建', '売建', '買戻', '転売', '決済売') THEN 'MANUAL'
      WHEN transaction_type = 'ＳＱ決済売' THEN 'SQ_SETTLEMENT'
      WHEN transaction_type = '権利割当' THEN 'SQ_ASSIGNMENT'
      WHEN transaction_type = '権利放棄' THEN 'SQ_EXPIRY'
      ELSE NULL
    END AS execution_method,
    quantity,
    unit_price,
    commission_amount,
    tax_amount,
    settlement_amount,
    ingested_at_utc
  FROM
    all_history
  WHERE
    security_type IN ('先物', 'オプション')
)

SELECT * FROM final
