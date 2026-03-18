# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Amplify Module
module "amplify" {
  source = "./modules/amplify"

  project_name        = var.project_name
  environment         = var.environment
  repository_url      = var.repository_url
  github_access_token = var.github_access_token
  branch_name         = var.branch_name
}

# CodePipeline Module
module "codepipeline" {
  source = "./modules/codepipeline"

  project_name           = var.project_name
  aws_region             = var.aws_region
  account_id             = data.aws_caller_identity.current.account_id
  repository_url         = var.repository_url
  github_access_token    = var.github_access_token
  branch_name            = var.branch_name
  terraform_state_bucket = "my-terraform-state-bucket-aasrith"
}
