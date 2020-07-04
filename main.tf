### DEFINING PROVIDER
##

provider "aws" {
    profile = "default"
    region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "woclandiner-clapp01.terraform.state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
