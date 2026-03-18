# Amplify Outputs
output "amplify_app_id" {
  description = "Amplify App ID"
  value       = module.amplify.app_id
}

output "amplify_app_url" {
  description = "Amplify App URL"
  value       = module.amplify.branch_url
}

output "amplify_default_domain" {
  description = "Amplify default domain"
  value       = module.amplify.default_domain
}

# CodePipeline Outputs
output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = module.codepipeline.codepipeline_name
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = module.codepipeline.codepipeline_arn
}

output "github_connection_arn" {
  description = "ARN of the GitHub connection (needs manual activation)"
  value       = module.codepipeline.github_connection_arn
}

output "artifacts_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  value       = module.codepipeline.artifacts_bucket
}

output "codebuild_plan_project" {
  description = "CodeBuild project for Terraform plan"
  value       = module.codepipeline.codebuild_plan_project
}

output "codebuild_apply_project" {
  description = "CodeBuild project for Terraform apply"
  value       = module.codepipeline.codebuild_apply_project
}
