# AWS CodePipeline Setup - Complete Guide

This guide walks you through setting up AWS CodePipeline for automated Terraform deployments.

## Prerequisites

Before you start, ensure you have:

1. ✅ AWS Account with admin access
2. ✅ AWS CLI installed and configured
3. ✅ Terraform 1.14.3+ installed
4. ✅ GitHub repository with your code
5. ✅ GitHub Personal Access Token (with repo permissions)

## Step-by-Step Setup

### Step 1: Prepare Your Variables

Create a `terraform.tfvars` file in the `terraform/` directory:

```bash
cd terraform
```

Create `terraform.tfvars`:

```hcl
# terraform/terraform.tfvars
aws_region          = "us-east-1"
project_name        = "react-amplify-app"
environment         = "prod"
branch_name         = "main"
repository_url      = "https://github.com/YOUR-USERNAME/YOUR-REPO"
github_access_token = "ghp_YOUR_GITHUB_TOKEN_HERE"
```

**Important:** Replace:
- `YOUR-USERNAME/YOUR-REPO` with your actual GitHub repository
- `ghp_YOUR_GITHUB_TOKEN_HERE` with your GitHub Personal Access Token

### Step 2: Initialize Terraform

```bash
cd terraform
terraform init
```

This will:
- Download AWS provider
- Initialize the backend (S3)
- Initialize modules

### Step 3: Review the Plan

```bash
terraform plan
```

This shows you what resources will be created:
- ✅ AWS Amplify App
- ✅ Amplify Branch
- ✅ CodePipeline
- ✅ 2 CodeBuild Projects (Plan & Apply)
- ✅ S3 Bucket for artifacts
- ✅ IAM Roles and Policies
- ✅ CodeStar GitHub Connection

### Step 4: Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Wait time:** ~2-3 minutes

After completion, you'll see outputs like:

```
Outputs:

amplify_app_url = "https://main.d1234567890abc.amplifyapp.com"
codepipeline_name = "react-amplify-app-terraform-pipeline"
github_connection_arn = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc-123"
artifacts_bucket = "react-amplify-app-codepipeline-artifacts-123456789012"
```

### Step 5: Activate GitHub Connection (CRITICAL!)

The pipeline won't work until you activate the GitHub connection.

**Option A: Using AWS Console**

1. Go to AWS Console: https://console.aws.amazon.com/
2. Navigate to: **Developer Tools** → **Settings** → **Connections**
3. Find connection: `react-amplify-app-github-connection`
4. Status will show: **Pending**
5. Click **Update pending connection**
6. Click **Install a new app** (or select existing GitHub app)
7. Authorize AWS Connector for GitHub
8. Select your repository
9. Click **Connect**
10. Status changes to: **Available** ✅

**Option B: Using AWS CLI**

```bash
# Get the connection ARN from terraform output
CONNECTION_ARN=$(terraform output -raw github_connection_arn)

# The connection needs manual activation in console
# CLI cannot complete the OAuth flow
echo "Activate this connection in AWS Console:"
echo $CONNECTION_ARN
```

### Step 6: Verify Pipeline Creation

**In AWS Console:**

1. Go to: **Developer Tools** → **CodePipeline** → **Pipelines**
2. Find: `react-amplify-app-terraform-pipeline`
3. You should see 4 stages:
   - 🔵 Source
   - 🔵 Plan
   - 🟡 Approve
   - 🔵 Apply

### Step 7: Trigger the Pipeline

**Method 1: Automatic Trigger (Recommended)**

Push any change to your `main` branch:

```bash
# Make a small change
echo "# Test" >> README.md
git add .
git commit -m "Test CodePipeline"
git push origin main
```

The pipeline will automatically start!

**Method 2: Manual Trigger**

In AWS Console:
1. Go to your pipeline
2. Click **Release change**
3. Confirm

### Step 8: Monitor Pipeline Execution

**Watch the Pipeline:**

1. **Source Stage** (1-2 minutes)
   - Pulls code from GitHub
   - Status: Running → Succeeded

2. **Plan Stage** (3-5 minutes)
   - Runs `terraform plan`
   - Check logs: Click **Details** → **Link to execution details**
   - Review CloudWatch logs to see what will change

3. **Approve Stage** (Manual)
   - Pipeline PAUSES here
   - Review the plan output in CloudWatch logs
   - Click **Review** → **Approve** or **Reject**

4. **Apply Stage** (3-5 minutes)
   - Runs `terraform apply`
   - Creates/updates your infrastructure
   - Status: Running → Succeeded

**Total time:** ~10-15 minutes (including approval wait)

## Understanding the Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Push to GitHub (main branch)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 1: Source                                            │
│  • CodePipeline detects push via webhook                    │
│  • Downloads code from GitHub                               │
│  • Stores in S3 artifacts bucket                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 2: Plan                                              │
│  • CodeBuild starts                                         │
│  • Installs Terraform 1.14.3                                │
│  • Runs: terraform init                                     │
│  • Runs: terraform plan                                     │
│  • Saves plan output                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 3: Approve (MANUAL)                                  │
│  • Pipeline PAUSES                                          │
│  • You review the plan                                      │
│  • Click "Approve" or "Reject"                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGE 4: Apply                                             │
│  • CodeBuild starts                                         │
│  • Installs Terraform 1.14.3                                │
│  • Runs: terraform init                                     │
│  • Runs: terraform apply -auto-approve                      │
│  • Infrastructure updated!                                  │
└─────────────────────────────────────────────────────────────┘
```

## Viewing Logs

### CodeBuild Logs (Detailed)

**Option 1: AWS Console**
1. Go to: **Developer Tools** → **CodeBuild** → **Build projects**
2. Click on: `react-amplify-app-terraform-plan` or `react-amplify-app-terraform-apply`
3. Click **Build history**
4. Click on a build
5. View **Build logs** tab

**Option 2: CloudWatch**
1. Go to: **CloudWatch** → **Logs** → **Log groups**
2. Find: `/aws/codebuild/react-amplify-app-terraform-plan`
3. Click on latest log stream
4. View full Terraform output

### Pipeline Execution History

1. Go to: **CodePipeline** → **Pipelines** → Your pipeline
2. Click **View history**
3. See all executions with timestamps and status

## Common Operations

### Approve a Pending Pipeline

```bash
# Get pipeline name
PIPELINE_NAME="react-amplify-app-terraform-pipeline"

# List pending approvals
aws codepipeline get-pipeline-state --name $PIPELINE_NAME

# Approve (you'll need the token from above command)
aws codepipeline put-approval-result \
  --pipeline-name $PIPELINE_NAME \
  --stage-name Approve \
  --action-name ManualApproval \
  --result status=Approved,summary="Approved via CLI" \
  --token <TOKEN_FROM_GET_PIPELINE_STATE>
```

### Manually Trigger Pipeline

```bash
aws codepipeline start-pipeline-execution \
  --name react-amplify-app-terraform-pipeline
```

### Check Pipeline Status

```bash
aws codepipeline get-pipeline-state \
  --name react-amplify-app-terraform-pipeline
```

### View Latest Build Logs

```bash
# Get latest build ID
BUILD_ID=$(aws codebuild list-builds-for-project \
  --project-name react-amplify-app-terraform-plan \
  --query 'ids[0]' --output text)

# Get build details
aws codebuild batch-get-builds --ids $BUILD_ID
```

## Troubleshooting

### Issue 1: Pipeline Fails at Source Stage

**Error:** "Could not access the repository"

**Solution:**
1. Verify GitHub connection is **Available** (not Pending)
2. Check repository URL in `terraform.tfvars`
3. Ensure repository exists and is accessible

```bash
# Verify connection status
aws codestar-connections get-connection \
  --connection-arn $(terraform output -raw github_connection_arn)
```

### Issue 2: Plan/Apply Stage Fails

**Error:** "Error: Failed to get existing workspaces"

**Solution:**
1. Check S3 state bucket exists: `my-terraform-state-bucket-aasrith`
2. Verify IAM permissions for CodeBuild role
3. Check CloudWatch logs for detailed error

```bash
# Verify state bucket
aws s3 ls s3://my-terraform-state-bucket-aasrith/

# Check CodeBuild role
aws iam get-role --role-name react-amplify-app-codebuild-role
```

### Issue 3: Terraform State Lock

**Error:** "Error acquiring the state lock"

**Solution:**
```bash
# Force unlock (use with caution!)
cd terraform
terraform force-unlock <LOCK_ID>
```

### Issue 4: GitHub Token Invalid

**Error:** "Invalid access token"

**Solution:**
1. Generate new GitHub token: https://github.com/settings/tokens
2. Required scopes: `repo`, `admin:repo_hook`
3. Update `terraform.tfvars`
4. Run `terraform apply` again

### Issue 5: Pipeline Stuck in Approval

**Solution:**
- Approve manually in console
- Or use CLI command (see "Common Operations" above)
- Or reject and fix issues

## Cost Breakdown

| Service | Cost | Free Tier |
|---------|------|-----------|
| CodePipeline | $1/month per pipeline | None |
| CodeBuild | $0.005/minute | 100 minutes/month |
| S3 (artifacts) | ~$0.023/GB/month | 5GB for 12 months |
| Amplify | $0.01/build minute | 1000 build minutes/month |
| Data Transfer | Varies | 100GB/month |

**Estimated monthly cost:** $1-5 (depending on usage)

## Best Practices

1. ✅ **Always review plan output** before approving
2. ✅ **Use separate pipelines** for dev/staging/prod
3. ✅ **Enable CloudWatch alarms** for pipeline failures
4. ✅ **Store sensitive data** in AWS Secrets Manager (not in code)
5. ✅ **Tag all resources** for cost tracking
6. ✅ **Set up SNS notifications** for approval requests
7. ✅ **Backup Terraform state** regularly

## Next Steps

### Add SNS Notifications

Get notified when approval is needed:

```hcl
# Add to terraform/modules/codepipeline/main.tf
resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-pipeline-notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"
}
```

### Add Multiple Environments

Create separate pipelines for dev/staging/prod:

```bash
# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

### Add Automated Tests

Add a test stage before approval:

```hcl
stage {
  name = "Test"
  
  action {
    name            = "RunTests"
    category        = "Test"
    owner           = "AWS"
    provider        = "CodeBuild"
    version         = "1"
    input_artifacts = ["source_output"]
    
    configuration = {
      ProjectName = aws_codebuild_project.tests.name
    }
  }
}
```

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted.

This will remove:
- CodePipeline
- CodeBuild projects
- S3 artifacts bucket
- IAM roles
- Amplify app
- All associated resources

**Note:** The GitHub connection may need manual deletion from AWS Console.

## Support

If you encounter issues:

1. Check CloudWatch logs first
2. Review IAM permissions
3. Verify GitHub connection status
4. Check Terraform state in S3
5. Review AWS service quotas

## Summary

You now have a fully automated CI/CD pipeline that:
- ✅ Automatically triggers on push to main
- ✅ Runs Terraform plan
- ✅ Requires manual approval
- ✅ Applies infrastructure changes
- ✅ Deploys your React app to Amplify

Every push to `main` will trigger this workflow automatically!
