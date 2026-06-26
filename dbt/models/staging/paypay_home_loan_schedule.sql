{{
  config(
    enabled = (target.name == 'dev' or var('enable_paypay_home_loan_schedule', false))
  )
}}

select
  to_date(raw_payload[0]::string, 'YYYY/MM/DD')                          as payment_date,
  try_to_number(raw_payload[1]::string)                                  as payment_amount,
  try_to_number(raw_payload[2]::string)                                  as principal_amount,
  try_to_number(raw_payload[3]::string)                                  as interest_amount,
  iff(raw_payload[4]::string = '-', null, try_to_number(raw_payload[4]::string)) as extra_principal_amount,
  iff(raw_payload[5]::string = '-', null, try_to_number(raw_payload[5]::string)) as extra_interest_amount,
  try_to_number(raw_payload[6]::string)                                  as annual_interest_rate,
  try_to_number(raw_payload[7]::string)                                  as remaining_balance,
  current_timestamp()                                                    as created_at
from DATALAKE_DB.PAYPAY_BANK.home_loan_schedule_raw
where raw_payload is not null
