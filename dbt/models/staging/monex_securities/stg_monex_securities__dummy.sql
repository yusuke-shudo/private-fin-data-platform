WITH source_data AS (
  SELECT * FROM {{ source('monex_securities', 'all_trade_and_cash_history_raw') }}
),

csv_split AS (
  SELECT
    PARSE_JSON('[' || raw_text || ']') AS col_array,
    NULLIF(col_array[3]::VARCHAR, '') AS product_name,
    file_path,
    line_number,
    SPLIT_PART(file_path, '/', -2) AS slice_year,
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
    product_name,
    ARRAY_REMOVE_AT(col_array, 3) AS col_array,
    SPLIT_PART(file_path, '/', -2) AS slice_year,
    ingested_at_utc
  FROM
    csv_split
)

SELECT * FROM final
