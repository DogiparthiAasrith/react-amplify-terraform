# React + AWS Amplify + Terraform

Deploy a React application to AWS Amplify using Terraform and GitHub Actions.

## Project Structure

```
├── frontend/                  # React application
│   ├── package.json
│   ├── public/
│   └── src/
├── terraform/                 # Infrastructure as Code
│   ├── main.tf               # Amplify resources
│   ├── provider.tf           # AWS provider & S3 backend
│   ├── variables.tf          # Input variables
│   └── outputs.tf            # Output values
└── .github/
    └── workflows/
        └── terraform.yml     # CI/CD pipeline
```

## Prerequisites

1. AWS Account with appropriate permissions
2. GitHub repository
3. S3 bucket for Terraform state

## Setup Steps

### Step 1: Create S3 Bucket for Terraform State

```bash
# Create the S3 bucket (run once)
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region us-east-1

# Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

### Step 2: Setup OIDC in AWS (via Console)

1. Go to AWS Console → IAM → Identity providers → Add provider
2. Select "OpenID Connect"
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click "Add provider"

Then create an IAM Role:

1. IAM → Roles → Create role
2. Select "Web identity" → Choose the GitHub provider → Audience: `sts.amazonaws.com`
3. Add condition: `token.actions.githubusercontent.com:sub` → StringLike → `repo:YOUR-ORG/YOUR-REPO:*`
4. Attach policies: `AmplifyFullAccess` + S3 access to your state bucket
5. Name the role (e.g., `github-actions-terraform-role`)

### Step 3: Configure GitHub Secrets

Add these secrets (Settings → Secrets and variables → Actions):

| Secret Name | Description |
|-------------|-------------|
| `AWS_ROLE_ARN` | IAM Role ARN (e.g., `arn:aws:iam::123456789012:role/github-actions-terraform-role`) |
| `GH_ACCESS_TOKEN` | GitHub PAT with `repo` and `admin:repo_hook` scopes |

### Step 4: Update Terraform Backend Configuration

Edit `terraform/provider.tf` and update the S3 bucket name:

```hcl
backend "s3" {
  bucket       = "your-actual-bucket-name"  # Change this
  key          = "environments/prod/terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
  encrypt      = true
}
```

### Step 5: Run the Workflow

1. Go to Actions tab in your GitHub repository
2. Select "Terraform AWS Amplify" workflow
3. Click "Run workflow"
4. Choose action:
   - `plan` - Preview changes only
   - `plan-and-apply` - Preview and apply changes
   - `plan-and-destroy` - Destroy all infrastructure (requires typing "DELETE")

## Workflow Actions

| Action | Description |
|--------|-------------|
| `plan` | Shows what Terraform will create/modify/destroy |
| `plan-and-apply` | Plans and applies changes to create/update infrastructure |
| `plan-and-destroy` | Plans and destroys all infrastructure (safety confirmation required) |

## Reusing This Template for Another Project

To deploy a different React app using this setup:

1. **Create a new S3 bucket or use a unique state key** in `provider.tf`
2. **Generate a GitHub Personal Access Token** with `repo` scope
3. **Push your React app** to GitHub (must have `frontend/` folder structure)
4. **Update required variables**:
   - `repository_url` - Your GitHub repo URL
   - `github_access_token` - Your PAT
   - `project_name` - Unique name for your app
5. **Run Terraform** (`init` → `plan` → `apply`)

## Local Development

```bash
# Frontend
cd frontend
npm install
npm start
```

## Local Terraform (Optional)

```bash
cd terraform

# Initialize
terraform init

# Plan
terraform plan \
  -var="repository_url=https://github.com/your-username/your-repo" \
  -var="github_access_token=ghp_xxx"

# Apply
terraform apply \
  -var="repository_url=https://github.com/your-username/your-repo" \
  -var="github_access_token=ghp_xxx"
```

## Outputs

After successful deployment:

- `amplify_app_id` - Amplify application ID
- `amplify_default_domain` - Default Amplify domain
- `amplify_branch_url` - Full URL to access your app

## Security Notes

- Never commit `terraform.tfvars` or secrets to version control
- Use GitHub Secrets for sensitive values
- S3 state bucket should have versioning enabled
- Consider enabling S3 bucket encryption at rest
