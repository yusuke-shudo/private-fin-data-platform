# =========================================================================
# Snowpipe (auto-ingest) サンプル: MONEX_SECURITIES.ALL_TRADE_AND_CASH_HISTORY_RAW
#
# 日次一括ロード(proc_task_load_raw_0300)から切り離し、S3 への新規配置を
# トリガーに増分ロードする。TRUNCATE は行わず、新規ファイルのみ追記される。
#
# 注意: Snowflakeは「1アカウント・1AWSリージョンにつきSQSキューを1つ」使い回す。
# https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3
# そのため notification_channel の値は pipe 固有ではなく、今後 pipe を追加しても
# 同じ値になる想定。AWS側の変数名も snowpipe_queue_arn（汎用名）としている。
#
# デプロイ手順(初回のみ、鶏卵問題があるため2段階になる):
#   1. 本ファイルを apply しパイプを作成する
#   2. 出力 monex_pipe_notification_channel の値を GitHub 変数
#      AWS_S3_SNOWPIPE_QUEUE_ARN に設定する
#   3. terraform/aws/platform/<env>/datalake.tf の S3 イベント通知を apply する
# =========================================================================
resource "snowflake_pipe" "monex_all_trade_and_cash_history" {
  database    = snowflake_database.datalake.name
  schema      = snowflake_schema.monex_securities.name
  name        = "PIPE_MONEX_ALL_TRADE_AND_CASH_HISTORY"
  auto_ingest = true
  comment     = "Snowpipe auto-ingest sample for MONEX all_trade_and_cash_history_raw | ${local.managed_comment}"

  # Snowpipeは通常のCOPY INTOと違い ON_ERROR=ABORT_STATEMENT 等の一部オプションを
  # サポートしない。エラー時はファイル単位でスキップされる。
  # https://docs.snowflake.com/en/sql-reference/sql/create-pipe#usage-notes
  copy_statement = <<-SQL
    COPY INTO ${snowflake_database.datalake.name}.${snowflake_schema.monex_securities.name}.ALL_TRADE_AND_CASH_HISTORY_RAW
    FROM (
      SELECT
        CONVERT_TIMEZONE('UTC', METADATA$START_SCAN_TIME)::TIMESTAMP_NTZ,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        $1
      FROM @${snowflake_stage_external_s3.monex_stage.fully_qualified_name}/all_trade_and_cash_history/
    )
    FILE_FORMAT = (FORMAT_NAME = '${snowflake_database.datalake.name}.COMMON.FF_NODELIMITER_SJIS')
  SQL

  # ステージのクラウド接続情報が変わった場合はパイプを作り直す
  # https://docs.snowflake.com/en/user-guide/data-load-snowpipe-manage#changing-the-cloud-parameters-of-the-referenced-stage
  lifecycle {
    replace_triggered_by = [
      snowflake_stage_external_s3.monex_stage.url,
      snowflake_stage_external_s3.monex_stage.storage_integration,
    ]
  }
}

resource "snowflake_tag_association" "monex_pipe_managed_by" {
  object_identifiers = [snowflake_pipe.monex_all_trade_and_cash_history.fully_qualified_name]
  object_type        = "PIPE"
  tag_id             = snowflake_tag.object_managed_by.fully_qualified_name
  tag_value          = "terraform"
}
