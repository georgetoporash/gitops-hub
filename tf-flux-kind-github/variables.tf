variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  sensitive   = true
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  sensitive   = true
  type        = string
}
