# AWS CodePipeline Deployment Guide

## Overview

This project uses AWS CodePipeline with Terraform to automatically deploy a React application to AWS Amplify.

## Architecture

```
GitHub Push → CodePipeline → CodeBuild (Terraform Plan) → Manual Approval → CodeBuild (Terraform Apply) → Amplify Deployment
```

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository
- GitHub Personal Access Token
- Terraform 1.14.3+
- AWS CLI configured

## Quick Start

### 1. Configure Variables

Create `terraform/terraform.tfvars`:

```hcl
aws_region          = "us-east-1"
project_name        = "Aasrith-codepipeline"
environment         = "prod"
branch_name         = "main"
repository_url      = "https://github.com/YOUR-USERNAME/YOUR-REPO"
github_access_token = "ghp_YOUR_TOKEN_HERE"
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Activate GitHub Connection

1. Go to AWS Console → Developer Tools → Connections
2. Find your connection (status: Pending)
3. Click "Update pending connection"
4. Authorize GitHub access
5. Complete the connection

### 4. Trigger Pipeline

```bash
git push origin main
```

The pipeline will automatically start!

## Pipeline Stages

### Stage 1: Source
- Pulls code from GitHub via CodeStar Connection
- Stores artifacts in S3

### Stage 2: Plan
- Runs `terraform plan` via CodeBuild
- Shows what infrastructure changes will be made
- Buildspec is inline using `yamlencode()`

### Stage 3: Approve
- Manual approval gate
- Review plan output in CloudWatch logs
- Approve or reject changes

### Stage 4: Apply
- Runs `terraform apply` via CodeBuild
- Creates/updates infrastructure
- Deploys React app to Amplify

## Buildspec Configuration

The buildspecs are now **inline** in the Terraform code using `yamlencode()`:

```hcl
buildspec = yamlencode({
  version = 0.2
  phases = {
    install = {
      commands = [
        "echo 'Installing Terraform...'",
        "wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip",
        "unzip terraform_1.14.3_linux_amd64.zip",
        "mv terraform /usr/local/bin/",
        "terraform --version"
      ]
    }
    pre_build = {
      commands = [
        "echo 'Initializing Terraform...'",
        "cd terraform",
        "terraform init"
      ]
    }
    build = {
      commands = [
        "echo 'Running Terraform Plan...'",
        "terraform plan -var=\"repository_url=$REPOSITORY_URL\" -var=\"github_access_token=$GITHUB_ACCESS_TOKEN\" -out=tfplan"
      ]
    }
  }
  artifacts = {
    files = [
      "terraform/tfplan",
      "terraform/**/*"
    ]
  }
})
```

## Module Structure

```
terraform/
├── main.tf                    # Root module
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── provider.tf                # AWS provider config
└── modules/
    ├── amplify/               # Amplify hosting
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── codepipeline/          # CI/CD pipeline
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Monitoring

### CloudWatch Logs

View detailed build logs:
1. Go to CloudWatch → Log groups
2. Find `/aws/codebuild/Aasrith-codepipeline-terraform-plan`
3. View latest log stream

### Pipeline Execution

Monitor pipeline:
1. Go to CodePipeline → Pipelines
2. Click on your pipeline
3. View execution history and stage details

## Troubleshooting

### Pipeline Fails at Source Stage

**Error:** "Could not access repository"

**Solution:**
- Verify GitHub connection is activated (not pending)
- Check repository URL is correct
- Ensure GitHub token has repo permissions

### Plan/Apply Stage Fails

**Error:** "DOWNLOAD_SOURCE failed"

**Solution:**
- Check CodeBuild IAM role has S3 permissions
- Verify artifacts bucket exists
- Check CloudWatch logs for detailed error

**Error:** "Terraform state lock"

**Solution:**
```bash
cd terraform
terraform force-unlock <LOCK_ID>
```

### YAML Parsing Error

**Error:** "Expected to be of struct type"

**Solution:**
- Ensure you've applied the latest Terraform changes
- Buildspec should use `yamlencode()` not heredoc
- Run `terraform apply` to update CodeBuild projects

## Making Changes

### Update Infrastructure

1. Modify Terraform files
2. Commit and push:
   ```bash
   git add .
   git commit -m "Update infrastructure"
   git push origin main
   ```
3. Pipeline automatically triggers
4. Review plan in CloudWatch
5. Approve in AWS Console
6. Changes applied automatically

### Update Pipeline Configuration

1. Modify `terraform/modules/codepipeline/main.tf`
2. Apply changes:
   ```bash
   cd terraform
   terraform apply
   ```
3. Pipeline updated with new configuration

## Cost Breakdown

| Service | Cost | Free Tier |
|---------|------|-----------|
| CodePipeline | $1/month | None |
| CodeBuild | $0.005/minute | 100 min/month |
| S3 | ~$0.023/GB | 5GB for 12 months |
| Amplify | $0.01/build min | 1000 min/month |

**Estimated:** $1-5/month depending on usage

## Best Practices

1. ✅ Always review plan output before approving
2. ✅ Use separate pipelines for dev/staging/prod
3. ✅ Store sensitive data in AWS Secrets Manager
4. ✅ Enable CloudWatch alarms for failures
5. ✅ Tag all resources for cost tracking
6. ✅ Backup Terraform state regularly
7. ✅ Use inline buildspecs with `yamlencode()`

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted.

**Note:** This removes:
- CodePipeline
- CodeBuild projects
- S3 artifacts bucket
- Amplify app
- All IAM roles

## Support

For issues:
1. Check CloudWatch logs first
2. Verify IAM permissions
3. Check GitHub connection status
4. Review Terraform state
5. Validate buildspec YAML

## Key Features

✅ Automated deployments on push
✅ Manual approval gate for safety
✅ Terraform state in S3
✅ Modular architecture
✅ Inline buildspecs (no external files)
✅ Comprehensive logging
✅ Secure by default

---

**Ready to deploy!** Follow the Quick Start section to get started.
