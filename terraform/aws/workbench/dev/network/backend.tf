terraform {
  backend "s3" {
    key    = "infrastructure/aws/workbench/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}