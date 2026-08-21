WITH sbi_source AS (
  SELECT
    'sbi_securities' AS source_institution,
    file_path,
    line_number,
    contract_name,
    trade_date,
    settlement_date,
    transaction_type,
    trade_side,
    trade_action,
    execution_method,
    quantity,
    unit_price,
    commission_amount,
    tax_amount,
    settlement_amount,
    ingested_at_utc
  FROM {{ ref('stg_sbi_securities__futures_options_trade_history') }}
),

monex_source AS (
  SELECT
    'monex_securities' AS source_institution,
    file_path,
    line_number,
    contract_name,
    trade_date,
    settlement_date,
    transaction_type,
    trade_side,
    trade_action,
    execution_method,
    quantity,
    unit_price,
    commission_amount,
    tax_amount,
    settlement_amount,
    ingested_at_utc
  FROM {{ ref('stg_monex_securities__futures_options_trade_history') }}
),

unioned AS (
  SELECT * FROM sbi_source
  UNION ALL
  SELECT * FROM monex_source
),

final AS (
  SELECT
    trade_date,
    settlement_date,
    contract_name,
    transaction_type,
    trade_side,
    trade_action,
    execution_method,
    source_institution,
    ROW_NUMBER() OVER (
      PARTITION BY trade_date, settlement_date, contract_name, transaction_type, source_institution 
      ORDER BY file_path, line_number
    ) AS seq_no,
    file_path,
    line_number,
    quantity,
    unit_price,
    commission_amount,
    tax_amount,
    settlement_amount,
    ingested_at_utc
  FROM unioned
)

SELECT * FROM final
