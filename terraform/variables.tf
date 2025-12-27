variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "react-amplify-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "repository_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "github_access_token" {
  description = "GitHub personal access token for Amplify"
  type        = string
  sensitive   = true
}

variable "branch_name" {
  description = "Branch to deploy"
  type        = string
  default     = "main"
}

# Note: amplify_service_role_arn variable removed
# The Amplify service role is now created by Terraform in main.tf
# This ensures proper trust relationship with amplify.amazonaws.com
