terraform {
  backend "s3" {
    key    = "infrastructure/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
