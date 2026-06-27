# Sample Data

- English version: [README.md](README.md)

このディレクトリには、入力データ形式の理解と変換ロジックの検証に使うサンプルファイルを配置する。

## ディレクトリ構成

- paypay_bank/: PayPay Bank のサンプルファイル（住宅ローンスケジュール用途）
- sbi_securities/: SBI Securities のサンプルファイル（特定口座譲渡損益用途）

## 利用上の注意

- 再現可能なテストのため、データセットは小さく安定した状態を保つ。
- 機微情報や個人情報はコミットしない。
- 公開リポジトリを前提に、匿名化またはマスキング済みの値のみを使う。
- サンプルファイル名は table_name_sample.ext 形式に統一する（例: home_loan_schedule_raw_sample.csv）。
