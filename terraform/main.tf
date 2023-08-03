module "gardner-infra" {
  source                      = "./modules"
  bucket_name                 = "discord-gardner-code"
  hour                        = "13"
  savings_time_notation       = "EDT"
}

terraform {
  backend "s3" {
    bucket  = "dmixon-garfield-terraform"
    key     = "terraform-statefiles/gardner-infra.tfstate"
    encrypt = "true"
    region  = "us-east-1"
  }
}

variable "region" {
  description = "the aws region to work in"
  default     = "us-east-1"
}

variable "profile" {
  description = "the aws profile to use"
  default     = "dmixon-garfield"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
