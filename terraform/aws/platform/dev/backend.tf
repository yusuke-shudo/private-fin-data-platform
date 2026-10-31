terraform {
  backend "s3" {
    key          = "infrastructure/aws/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
