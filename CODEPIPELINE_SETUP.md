# AWS CodePipeline Setup Guide

This guide will help you migrate from GitHub Actions to AWS CodePipeline for your Terraform infrastructure deployment.

## Architecture Overview

The CodePipeline setup includes:
- **Source Stage**: Pulls code from GitHub using CodeStar Connections
- **Plan Stage**: Runs `terraform plan` via CodeBuild
- **Approval Stage**: Manual approval gate before applying changes
- **Apply Stage**: Runs `terraform apply` via CodeBuild

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform 1.14.3+ installed locally
3. GitHub repository with your code
4. AWS account with necessary permissions

## Setup Steps

### 1. Deploy the CodePipeline Infrastructure

First, you need to apply the Terraform configuration that creates the CodePipeline:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will create:
- S3 bucket for pipeline artifacts
- CodePipeline with Source, Plan, Approve, and Apply stages
- CodeBuild projects for Terraform operations
- IAM roles and policies
- GitHub CodeStar Connection (requires manual activation)

### 2. Activate GitHub Connection

After the initial apply, you need to manually activate the GitHub connection:

1. Go to AWS Console → Developer Tools → Connections
2. Find the connection named `<project-name>-github-connection`
3. Click "Update pending connection"
4. Follow the prompts to authorize AWS access to your GitHub repository
5. Complete the connection setup

### 3. Verify Pipeline Execution

Once the connection is activated:

1. Go to AWS Console → CodePipeline
2. Find your pipeline: `<project-name>-terraform-pipeline`
3. The pipeline should automatically trigger on the next push to your main branch
4. Monitor the execution through each stage

### 4. Pipeline Workflow

**On every push to main branch:**
1. **Source**: Code is pulled from GitHub
2. **Plan**: Terraform plan runs and shows what will change
3. **Approval**: Manual approval required (check CloudWatch logs for plan output)
4. **Apply**: After approval, Terraform apply executes the changes

## Monitoring and Logs

- **CodePipeline Console**: View pipeline execution status
- **CodeBuild Console**: View build logs for Plan and Apply stages
- **CloudWatch Logs**: Detailed logs at `/aws/codebuild/<project-name>-terraform-*`

## Environment Variables

The following variables are passed to CodeBuild:
- `GITHUB_ACCESS_TOKEN`: Your GitHub personal access token
- `REPOSITORY_URL`: Your GitHub repository URL

These are configured in the Terraform variables.

## Cost Considerations

- CodePipeline: $1/month per active pipeline
- CodeBuild: Pay per build minute (FREE tier: 100 build minutes/month)
- S3: Storage costs for artifacts (minimal)
- CodeStar Connections: No additional charge

## Troubleshooting

### Pipeline fails at Source stage
- Verify GitHub connection is activated
- Check repository URL is correct
- Ensure branch name matches configuration

### Plan/Apply stage fails
- Check CodeBuild logs in CloudWatch
- Verify IAM role has necessary permissions
- Ensure Terraform state bucket exists and is accessible

### Manual approval not appearing
- Check SNS topic configuration (if you want email notifications)
- Verify you have permissions to approve in CodePipeline

## Differences from GitHub Actions

| Feature | GitHub Actions | AWS CodePipeline |
|---------|---------------|------------------|
| Trigger | Push to branch | Push to branch (via webhook) |
| Approval | Manual workflow dispatch | Built-in approval stage |
| Logs | GitHub UI | CloudWatch Logs |
| Cost | Free for public repos | ~$1/month + build time |
| Integration | Native GitHub | CodeStar Connection |

## Next Steps

1. Consider adding SNS notifications for approval requests
2. Add additional stages for testing or validation
3. Configure branch-specific pipelines for dev/staging/prod
4. Set up CloudWatch alarms for pipeline failures

## Cleanup

To remove the CodePipeline infrastructure:

```bash
cd terraform
terraform destroy
```

Note: This will destroy the pipeline but keep your Amplify app unless you also remove those resources.
