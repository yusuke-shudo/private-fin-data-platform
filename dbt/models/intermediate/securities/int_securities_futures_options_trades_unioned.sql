WITH stg_sbi AS (
  SELECT * FROM {{ ref('stg_sbi_securities__futures_options_trade_history') }}
),

stg_monex AS (
  SELECT * FROM {{ ref('stg_monex_securities__futures_options_trade_history') }}
),

xxx AS (
  SELECT
    'SBI' AS source_institution,
    file_path,
    line_number,
    trade_date,
    settlement_date,
    contract_name,
    product_name,
    contract_lot_size,
    product_type,
    sq_week,
    option_type,
    strike_price,
    transaction_type,
    trade_action,
    trade_side,
    execution_method,
    unit_price,
    quantity,
    execution_amount,
    commission_amount,
    tax_amount,
    settlement_amount,
    position_open_date,
    position_open_price,
    position_open_execution_amount,
    position_open_commission_amount,
    position_open_tax_amount,
    position_open_settlement_amount,
    realized_profit_loss,
    ingested_at_utc
  FROM
    stg_sbi
),

yyy AS (
  SELECT
    'MONEX' AS source_institution,
    file_path,
    line_number,
    trade_date,
    settlement_date,
    contract_name,
    product_name,
    contract_lot_size,
    product_type,
    sq_week,
    option_type,
    strike_price,
    transaction_type,
    trade_action,
    trade_side,
    execution_method,
    unit_price,
    quantity,
    execution_amount,
    commission_amount,
    tax_amount,
    settlement_amount,
    NULL AS position_open_date,
    NULL AS position_open_price,
    NULL AS position_open_execution_amount,
    NULL AS position_open_commission_amount,
    NULL AS position_open_tax_amount,
    NULL AS position_open_settlement_amount,
    NULL AS realized_profit_loss,
    ingested_at_utc
  FROM
    stg_monex
),

unioned AS (
  SELECT * FROM xxx
  UNION ALL
  SELECT * FROM yyy
),

final AS (
  SELECT
    trade_date,
    settlement_date,
    product_name,
    contract_lot_size,
    product_type,
    sq_week,
    option_type,
    strike_price,
    trade_action,
    trade_side,
    execution_method,
    source_institution,
    ROW_NUMBER() OVER (
      PARTITION BY
        trade_date, settlement_date, product_name, product_type, sq_week, option_type, strike_price,
        trade_action, trade_side, execution_method, source_institution
      ORDER BY file_path, line_number
    ) AS seq_no,
    contract_name,
    transaction_type,
    unit_price,
    quantity,
    execution_amount,
    commission_amount,
    tax_amount,
    settlement_amount,
    position_open_date,
    position_open_price,
    position_open_execution_amount,
    position_open_commission_amount,
    position_open_tax_amount,
    position_open_settlement_amount,
    realized_profit_loss,
    ingested_at_utc
  FROM unioned
)

SELECT * FROM final
