WITH all_history AS (
  SELECT * FROM {{ ref('stg_monex_securities__all_trade_and_cash_history') }}
),

final AS (
  SELECT
    file_path,
    line_number,
    trade_date,
    settlement_date,
    security_name AS contract_name,
    CASE
      WHEN contract_name LIKE '日経225マイクロ%' THEN 'Nikkei 225 micro'
      WHEN contract_name LIKE '日経225ミニ%' THEN 'Nikkei 225 mini'
      WHEN contract_name LIKE '日経225%' THEN 'Nikkei 225'
      ELSE contract_name
    END AS product_name,
    CASE
      WHEN ENDSWITH(product_name, 'micro') THEN 10
      WHEN ENDSWITH(product_name, 'mini') THEN 100
      ELSE 1000
    END AS contract_lot_size,
    CASE
      WHEN security_type = '先物' THEN 'Futures'
      WHEN security_type = 'オプション' THEN 'Options'
    END AS product_type,
    IFF(
      product_type = 'Options' AND product_name = 'Nikkei 225 mini',
      REGEXP_SUBSTR(contract_name, '^.* (../..-.W)', 1, 1, 'e', 1),
      REGEXP_SUBSTR(contract_name, '^.* (../..)', 1, 1, 'e', 1) || '-2W'
    ) AS sq_week,
    CASE
      WHEN contract_name LIKE '%ｺｰﾙ%' THEN 'CALL'
      WHEN contract_name LIKE '%ﾌﾟｯﾄ%' THEN 'PUT'
    END AS option_type,
    IFF(
      product_type = 'Options',
      REGEXP_SUBSTR(contract_name, '([0-9]+)$', 1, 1, 'e', 1)::NUMBER,
      NULL
    ) AS strike_price,
    transaction_type,
    CASE
      WHEN transaction_type IN ('買建', '買戻') THEN 'BUY'
      WHEN transaction_type IN ('売建', '転売', '決済売', 'ＳＱ決済売') THEN 'SELL'
      WHEN transaction_type IN ('権利割当', '権利消滅') THEN 'BUY'
      WHEN transaction_type = '権利放棄' THEN 'SELL'
    END AS trade_side,
    CASE
      WHEN transaction_type IN ('買建', '売建') THEN 'OPEN'
      WHEN transaction_type IN ('買戻', '転売', '決済売', 'ＳＱ決済売') THEN 'CLOSE'
      WHEN transaction_type IN ('権利割当', '権利消滅', '権利放棄') THEN 'CLOSE'
    END AS trade_action,
    CASE
      WHEN transaction_type IN ('買建', '売建', '買戻', '転売', '決済売') THEN 'MANUAL'
      WHEN transaction_type = 'ＳＱ決済売' THEN 'SQ_SETTLEMENT'
      WHEN transaction_type = '権利割当' THEN 'SQ_ASSIGNMENT'
      WHEN transaction_type IN ('権利放棄', '権利消滅') THEN 'SQ_EXPIRY'
    END AS execution_method,
    unit_price,
    quantity,
    FLOOR(unit_price * quantity * contract_lot_size) AS execution_amount,
    commission_amount,
    tax_amount,
    IFF(
      product_type = 'Options' AND trade_side = 'BUY',
      - settlement_amount,
      settlement_amount
    ) AS settlement_amount,
    ingested_at_utc
  FROM
    all_history
  WHERE
    security_type IN ('先物', 'オプション')
)

SELECT * FROM final
