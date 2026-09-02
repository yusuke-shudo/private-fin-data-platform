# =========================================================================
# Snowpipe (auto-ingest) サンプル: MONEX_SECURITIES.ALL_TRADE_AND_CASH_HISTORY_RAW
#
# 日次一括ロード(proc_task_load_raw_0300)から切り離し、S3 への新規配置を
# トリガーに増分ロードする。TRUNCATE は行わず、新規ファイルのみ追記される。
#
# S3→SNS→SQS 経由で構成する(S3→SQS直結ではない)。
# 理由: 外部ステージがS3アクセスポイントのエイリアスをURLに使っているため、
# Snowflakeが自動生成するSQSキューのリソースポリシーに実バケットを正しく登録でき
# ず、S3→SQS直結だと PutBucketNotificationConfiguration が
# "Unable to validate the following destination configurations" で失敗した
# (Terraform・AWSコンソール双方で再現)。
# SNSを介すことで、S3→SNSの許可は私たちが実バケットARNで直接書ける
# (terraform/aws/platform/<env>/datalake.tf)ので、この問題を回避できる。
#
# トピック名はAWS側と同じ命名規則から機械的に決まるので、bootstrap的な
# ARNの受け渡しは不要。ただし Snowflake がこのトピックをSubscribeするには
# AWS側でSubscribe許可を追加する必要がある。
#
# デプロイ手順:
#   1. AWS側をapplyしてSNSトピックとS3→SNSのイベント通知を作成する
#   2. SELECT SYSTEM$GET_AWS_SNS_IAM_POLICY('<topic_arn>'); を実行し、
#      返ってくるポリシーの Principal ARN を控える
#   3. その値を GitHub変数 AWS_SNS_SNOWFLAKE_SUBSCRIBER_ARN に設定し、
#      AWS側(datalake.tf)を再applyしてSNSトピックポリシーにSubscribe許可を追加する
#   4. 本ファイルをapplyしてaws_sns_topic_arn付きのpipeを作り直す。
#      SnowflakeがSNSトピックをSubscribeする
# =========================================================================
resource "snowflake_pipe" "monex_all_trade_and_cash_history" {
  database          = snowflake_database.datalake.name
  schema            = snowflake_schema.monex_securities.name
  name              = "PIPE_MONEX_ALL_TRADE_AND_CASH_HISTORY"
  auto_ingest       = true
  aws_sns_topic_arn = local.snowpipe_sns_topic_arn
  comment           = "Snowpipe auto-ingest sample for MONEX all_trade_and_cash_history_raw (via SNS) | ${local.managed_comment}"

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
