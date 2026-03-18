# Terraform Infrastructure

This directory contains the Terraform configuration for deploying a React application with AWS Amplify and CodePipeline for CI/CD.

## Structure

```
terraform/
├── main.tf                    # Root module configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── provider.tf                # Provider configuration
├── buildspecs/                # CodeBuild build specifications
│   ├── terraform-plan.yml
│   └── terraform-apply.yml
└── modules/
    ├── amplify/               # Amplify hosting module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── codepipeline/          # CI/CD pipeline module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Modules

### Amplify Module
Creates AWS Amplify application for hosting the React frontend with automatic builds and deployments.

### CodePipeline Module
Creates a complete CI/CD pipeline with Terraform plan, manual approval, and apply stages.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform 1.14.3 or later
3. GitHub repository with your code
4. S3 bucket for Terraform state (already configured: `my-terraform-state-bucket-aasrith`)

## Quick Start

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Create terraform.tfvars**
   ```hcl
   repository_url      = "https://github.com/your-username/your-repo"
   github_access_token = "ghp_your_token_here"
   project_name        = "react-amplify-app"
   environment         = "prod"
   branch_name         = "main"
   aws_region          = "us-east-1"
   ```

3. **Plan and Apply**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Activate GitHub Connection**
   - Go to AWS Console → Developer Tools → Connections
   - Find the connection and activate it
   - Authorize GitHub access

## Variables

| Name | Description | Default | Required |
|------|-------------|---------|----------|
| aws_region | AWS region | us-east-1 | no |
| project_name | Project name | react-amplify-app | no |
| environment | Environment | prod | no |
| repository_url | GitHub repository URL | - | yes |
| github_access_token | GitHub token | - | yes |
| branch_name | Branch to deploy | main | no |

## Outputs

After applying, you'll get:
- Amplify app URL
- CodePipeline name and ARN
- GitHub connection ARN (needs activation)
- Artifacts bucket name
- CodeBuild project names

## Pipeline Workflow

1. Push code to main branch
2. CodePipeline automatically triggers
3. Source stage pulls code from GitHub
4. Plan stage runs Terraform plan
5. Manual approval required
6. Apply stage executes Terraform apply
7. Amplify automatically builds and deploys frontend

## Cost Estimate

- CodePipeline: ~$1/month
- CodeBuild: ~$0.005/minute (100 free minutes/month)
- S3: Minimal storage costs
- Amplify: Based on build minutes and data transfer

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Troubleshooting

### Pipeline fails at Source stage
- Verify GitHub connection is activated
- Check repository URL format

### Plan/Apply fails
- Check CodeBuild logs in CloudWatch
- Verify IAM permissions
- Ensure state bucket is accessible

### Amplify build fails
- Check build logs in Amplify console
- Verify GitHub token has repo access
