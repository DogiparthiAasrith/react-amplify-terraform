# CodePipeline Module

This module creates an AWS CodePipeline for automated Terraform deployments.

## Resources Created

- CodePipeline with 4 stages (Source, Plan, Approve, Apply)
- CodeBuild projects for Terraform plan and apply
- S3 bucket for pipeline artifacts
- IAM roles and policies
- CodeStar GitHub connection

## Pipeline Stages

1. **Source**: Pulls code from GitHub
2. **Plan**: Runs Terraform plan
3. **Approve**: Manual approval gate
4. **Apply**: Runs Terraform apply

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Name of the project | string | yes |
| aws_region | AWS region | string | yes |
| account_id | AWS Account ID | string | yes |
| repository_url | GitHub repository URL | string | yes |
| github_access_token | GitHub personal access token | string | yes |
| branch_name | Branch to monitor | string | yes |
| terraform_state_bucket | S3 bucket for Terraform state | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| codepipeline_name | Name of the CodePipeline |
| codepipeline_arn | ARN of the CodePipeline |
| github_connection_arn | ARN of the GitHub connection |
| artifacts_bucket | S3 bucket for artifacts |
| codebuild_plan_project | CodeBuild project for plan |
| codebuild_apply_project | CodeBuild project for apply |

## Usage

```hcl
module "codepipeline" {
  source = "./modules/codepipeline"

  project_name           = "my-app"
  aws_region             = "us-east-1"
  account_id             = "123456789012"
  repository_url         = "https://github.com/user/repo"
  github_access_token    = var.github_token
  branch_name            = "main"
  terraform_state_bucket = "my-tfstate-bucket"
}
```

## Post-Deployment Steps

After deploying this module, you must manually activate the GitHub connection:

1. Go to AWS Console → Developer Tools → Connections
2. Find the connection and click "Update pending connection"
3. Authorize AWS access to your GitHub repository
