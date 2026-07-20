terraform {
  backend "s3" {
    key    = "infrastructure/aws/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
