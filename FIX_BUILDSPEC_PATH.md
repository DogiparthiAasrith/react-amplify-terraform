# Fix: Buildspec File Path Error

## Problem
CodeBuild is looking for the buildspec file in the wrong location, causing the error:
```
YAML_FILE_ERROR Message: stat /codebuild/output/src.../src/terraform.yml: no such file or directory
```

## Root Cause
The Terraform module was using `file()` function which reads the file at Terraform apply time from the local machine, but CodeBuild needs the path relative to the repository root.

## Solution

### Step 1: Verify the buildspec file exists in your repository

Check that this file exists in your GitHub repo:
```
terraform/buildspecs/terraform.yml
```

You can see it in your screenshot - it's there! ✅

### Step 2: Update the Terraform infrastructure

The code has been fixed. Now apply the changes:

```bash
cd terraform

# Pull the latest changes if you committed them
git pull

# Apply the fix
terraform plan
terraform apply
```

Type `yes` when prompted.

### Step 3: Commit and push the fix to GitHub

```bash
# Add all changes
git add .

# Commit
git commit -m "Fix buildspec path in CodeBuild projects"

# Push to GitHub
git push origin main
```

### Step 4: Trigger the pipeline again

The pipeline should automatically trigger after the push. Or manually trigger it:

**Option A: AWS Console**
1. Go to CodePipeline
2. Select your pipeline: `react-amplify-app-terraform-pipeline`
3. Click **Release change**

**Option B: AWS CLI**
```bash
aws codepipeline start-pipeline-execution \
  --name react-amplify-app-terraform-pipeline
```

## What Changed?

**Before (WRONG):**
```hcl
source {
  type      = "CODEPIPELINE"
  buildspec = file("${path.module}/../../buildspecs/terraform.yml")
}
```
This reads the file from your local machine during `terraform apply`.

**After (CORRECT):**
```hcl
source {
  type      = "CODEPIPELINE"
  buildspec = "terraform/buildspecs/terraform.yml"
}
```
This tells CodeBuild to look for the file in the repository at runtime.

## Verification

After the fix, the CodeBuild logs should show:

```
[Container] Running on CodeBuild
[Container] Waiting for agent ping
[Container] Phase is DOWNLOAD_SOURCE
[Container] CODEBUILD_SRC_DIR=/codebuild/output/src...
[Container] Phase complete: DOWNLOAD_SOURCE
[Container] Phase is INSTALL
[Container] Installing Terraform...
```

No more `YAML_FILE_ERROR`! ✅

## Alternative: Inline Buildspec (Optional)

If you still have issues, you can embed the buildspec directly in Terraform:

```hcl
source {
  type = "CODEPIPELINE"
  buildspec = <<-EOT
    version: 0.2
    phases:
      install:
        commands:
          - echo "Installing Terraform..."
          - wget https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip
          - unzip terraform_1.14.3_linux_amd64.zip
          - mv terraform /usr/local/bin/
          - terraform --version
      pre_build:
        commands:
          - echo "Initializing Terraform..."
          - cd terraform
          - terraform init
      build:
        commands:
          - |
            if [ "$TERRAFORM_ACTION" = "plan" ]; then
              echo "Running Terraform Plan..."
              terraform plan -var="repository_url=$REPOSITORY_URL" -var="github_access_token=$GITHUB_ACCESS_TOKEN" -out=tfplan
            elif [ "$TERRAFORM_ACTION" = "apply" ]; then
              echo "Running Terraform Apply..."
              terraform apply -auto-approve -var="repository_url=$REPOSITORY_URL" -var="github_access_token=$GITHUB_ACCESS_TOKEN"
            fi
      post_build:
        commands:
          - echo "Terraform $TERRAFORM_ACTION completed successfully"
    artifacts:
      files:
        - terraform/tfplan
        - terraform/**/*
  EOT
}
```

But the file reference method is cleaner and recommended.
