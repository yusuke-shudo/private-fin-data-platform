terraform {
  backend "s3" {
    key    = "infrastructure/terraform.tfstate"
    region = "ap-northeast-1"
    use_s3_express_and_native_locking = true
    encrypt = true
  }
}
