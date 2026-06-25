# SBI Securities Sample Data

This directory contains sample data for the tokutei account profit/loss report.

## Files

- sbi_tokutei_profit_loss_report_raw_sample.csv: sanitized sample used for development and tests.
- build_sample_from_raw.ps1: generator script to create sanitized sample data from raw input.

## Generate Sample

Run from repository root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./sample_data/sbi_securities/build_sample_from_raw.ps1 \
  -InputFile ./sample_data/sbi_securities/sbi_tokutei_profit_loss_report_raw_sample.csv \
  -OutputFile ./sample_data/sbi_securities/sbi_tokutei_profit_loss_report_raw_sample.csv \
  -YearShift -20 \
  -AmountScale 0.41
```

## Transformation Rules

- Shift date-like values by year offset (default: -20 years).
- Scale integer amounts by multiplier (default: 0.41).
- Replace security names with stable synthetic labels (SAMPLE_STOCK_XXX).
- Replace 4-digit security codes with stable synthetic codes (7001, 7002, ...).
