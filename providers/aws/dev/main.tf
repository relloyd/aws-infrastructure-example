terraform {
  backend "s3" {
    bucket = "state.halfpipe.sh"
    key    = "infrastructure/matchesfashion-terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  version = "~> 2.7"
  region  = "eu-west-2"

  // only allow terraform to run in this account it
  allowed_account_ids = ["446258565969"]
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=f1e45410288f15ed4f5e45449c11ea7b0d9ee374"

  name = "dev-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "euw1-az3"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = false

  enable_nat_gateway = false
  single_nat_gateway = false

  public_subnet_tags = {
    Name = "public"
  }

  tags = {
    Owner       = "richardlloyd"
    Environment = "dev"
    project = "matchesfashion"
  }

  vpc_tags = {
    Name = "vpc-dev"
  }
}
