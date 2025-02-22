terraform {
  backend "s3" {
    bucket         = "sabrbull-terraform-state"
    key            = "your-monorepo/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
