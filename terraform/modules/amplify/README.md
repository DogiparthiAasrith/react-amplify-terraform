# Amplify Module

This module creates an AWS Amplify application for hosting a React frontend.

## Resources Created

- AWS Amplify App
- Amplify Branch (main)

## Features

- Automatic builds on push
- Custom SPA routing rules
- Environment-specific configurations
- GitHub integration

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Name of the project | string | yes |
| environment | Environment name (prod/dev) | string | yes |
| repository_url | GitHub repository URL | string | yes |
| github_access_token | GitHub personal access token | string | yes |
| branch_name | Branch to deploy | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| app_id | Amplify App ID |
| app_arn | Amplify App ARN |
| default_domain | Amplify default domain |
| branch_name | Amplify branch name |
| branch_url | URL for the Amplify branch |

## Usage

```hcl
module "amplify" {
  source = "./modules/amplify"

  project_name        = "my-app"
  environment         = "prod"
  repository_url      = "https://github.com/user/repo"
  github_access_token = var.github_token
  branch_name         = "main"
}
```
