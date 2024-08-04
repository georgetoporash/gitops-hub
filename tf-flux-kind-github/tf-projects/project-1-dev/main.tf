terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# resource "aws_s3_bucket" "my_bucket_project_1_dev" {
#   bucket = "georgetoporash-project-1-dev"
#   tags = {
#     Name        = "project-1-dev"
#     Environment = "Develop"
#   }
# }