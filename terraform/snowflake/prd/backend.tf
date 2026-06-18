terraform {
  backend "s3" {
    key    = "infrastructure/snowflake/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
