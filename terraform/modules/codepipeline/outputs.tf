output "codepipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.terraform_pipeline.name
}

output "codepipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.terraform_pipeline.arn
}

output "github_connection_arn" {
  description = "ARN of the GitHub connection (needs manual activation)"
  value       = aws_codestarconnections_connection.github.arn
}

output "artifacts_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "codebuild_plan_project" {
  description = "CodeBuild project for Terraform plan"
  value       = aws_codebuild_project.terraform_plan.name
}

output "codebuild_apply_project" {
  description = "CodeBuild project for Terraform apply"
  value       = aws_codebuild_project.terraform_apply.name
}
