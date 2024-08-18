terraform {
  required_version = ">= 1.5.0"


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

# resource "aws_s3_bucket" "my_bucket_project_2_dev" {
#   bucket = "georgetoporash-project-2-dev"
#   tags = {
#     Name        = "project-2-dev"
#     Environment = "Develop"
#   }
# }