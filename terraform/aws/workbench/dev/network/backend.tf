terraform {
  backend "s3" {
    key    = "infrastructure/aws/workbench/dev/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}