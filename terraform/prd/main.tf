resource "snowflake_database" "datalake" {
  name = "DATALAKE_DB"
}

resource "snowflake_database" "datawarehouse" {
  name = "DATAWAREHOUSE_DB"
}

resource "snowflake_database" "datamart" {
  name = "DATAMART_DB"
}
