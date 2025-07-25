terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.4.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

