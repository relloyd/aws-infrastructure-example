terraform {
  backend "s3" {
    bucket = "state.halfpipe.sh"
    key    = "infrastructure/bootstrap-terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "~> 2.7"
  region  = "eu-west-2"

  // only allow terraform to run in this account it
  allowed_account_ids = ["446258565969"]
}
