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

# resource "aws_s3_bucket" "my_bucket_project_2_prod" {
#   bucket = "georgetoporash-project-2-prod"
#   tags = {
#     Name        = "project-2-prod"
#     Environment = "Production"
#   }
# }