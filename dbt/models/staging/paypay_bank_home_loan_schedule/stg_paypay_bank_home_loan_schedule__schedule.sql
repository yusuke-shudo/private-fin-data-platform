with source_data as (
  select
    *
  from {{ source('paypay_bank', 'home_loan_schedule_raw') }}
),
parsed_data as (
  select
    to_date(trim(split_part(raw_text, ',', 1)), 'YYYY/MM/DD')                                                    as payment_date,
    try_to_number(trim(split_part(raw_text, ',', 2)))                                                            as payment_amount,
    try_to_number(trim(split_part(raw_text, ',', 3)))                                                            as principal_amount,
    try_to_number(trim(split_part(raw_text, ',', 4)))                                                            as interest_amount,
    iff(trim(split_part(raw_text, ',', 5)) = '-', null, try_to_number(trim(split_part(raw_text, ',', 5))))    as extra_principal_amount,
    iff(trim(split_part(raw_text, ',', 6)) = '-', null, try_to_number(trim(split_part(raw_text, ',', 6))))    as extra_interest_amount,
    try_to_number(trim(split_part(raw_text, ',', 7)))                                                            as annual_interest_rate,
    try_to_number(trim(split_part(raw_text, ',', 8)))                                                            as remaining_balance,
    ingest_at_utc                                                                                                as ingested_at,
    file_path,
    line_number,
    current_timestamp()                                                                                          as created_at
  from source_data
),
final as (
  select * from parsed_data
)
select * from final
