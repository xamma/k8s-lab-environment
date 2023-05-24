terraform {
  backend "s3" {
    bucket = "tfstate-techpre-1541234"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "app-state"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "${var.aws_region}"
}