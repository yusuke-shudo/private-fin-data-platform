terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "infrastructure/snowflake/workbench/identities/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
