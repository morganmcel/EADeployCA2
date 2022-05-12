terraform {
  backend "s3" {
    bucket = "morganmc-tf-state"
    key    = "msc-devops/eadeployCA2v2"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = var.AWS_REGION
}
