# URGENT: Fix CodePipeline Buildspec Issue

## Current Situation
- ✅ `buildspecs/terraform.yml` exists in your repository
- ✅ File is committed to Git
- ❌ CodeBuild projects in AWS still reference the OLD path
- ❌ Pipeline is failing because AWS CodeBuild configuration is outdated

## The Problem
The Terraform code has been updated locally, but you haven't applied it to AWS yet. The CodeBuild projects in AWS are still looking for the old path.

## SOLUTION: Apply Terraform Changes

### Step 1: Navigate to terraform directory
```powershell
cd terraform
```

### Step 2: Check what will change
```powershell
terraform plan
```

You should see changes to:
- `aws_codebuild_project.terraform_plan` (will be updated in-place)
- `aws_codebuild_project.terraform_apply` (will be updated in-place)

Specifically, the buildspec path will change from:
- OLD: `terraform/buildspecs/terraform.yml`
- NEW: `buildspecs/terraform.yml`

### Step 3: Apply the changes
```powershell
terraform apply
```

Type `yes` when prompted.

### Step 4: Verify in AWS Console

1. Go to AWS Console → CodeBuild → Build projects
2. Click on `Aasrith-codepipeline-terraform-plan`
3. Click "Edit" → "Buildspec"
4. Verify it shows: `buildspecs/terraform.yml`

### Step 5: Trigger the pipeline again

**Option A: Push a change**
```powershell
cd ..
echo "# Test" >> README.md
git add .
git commit -m "Trigger pipeline after buildspec fix"
git push origin main
```

**Option B: Manual trigger in AWS Console**
1. Go to CodePipeline → Your pipeline
2. Click "Release change"

## Expected Result

The pipeline should now:
1. ✅ Source stage: Pull code from GitHub
2. ✅ Plan stage: Find `buildspecs/terraform.yml` and run successfully
3. ⏸️ Approve stage: Wait for your approval
4. ✅ Apply stage: Run successfully after approval

## If Terraform Apply Fails

### Error: "No changes detected"
This means Terraform thinks nothing changed. Force refresh:
```powershell
terraform refresh
terraform plan
terraform apply
```

### Error: "terraform.tfvars not found"
Create the file:
```powershell
# Create terraform.tfvars in terraform/ directory
@"
aws_region          = "us-east-1"
project_name        = "Aasrith-codepipeline"
environment         = "prod"
branch_name         = "main"
repository_url      = "https://github.com/DogiparthiAasrith/react-amplify-terraform"
github_access_token = "YOUR_GITHUB_TOKEN_HERE"
"@ | Out-File -FilePath terraform.tfvars -Encoding utf8
```

Replace `YOUR_GITHUB_TOKEN_HERE` with your actual token.

### Error: "State lock"
```powershell
terraform force-unlock LOCK_ID
```

## Alternative: Update CodeBuild Directly in AWS Console

If Terraform is not working, you can manually update CodeBuild:

1. Go to AWS Console → CodeBuild → Build projects
2. Click on `Aasrith-codepipeline-terraform-plan`
3. Click "Edit" → "Buildspec"
4. Change "Buildspec name" from `terraform/buildspecs/terraform.yml` to `buildspecs/terraform.yml`
5. Click "Update buildspec"
6. Repeat for `Aasrith-codepipeline-terraform-apply`

## Verification Commands

```powershell
# Check if file exists locally
ls buildspecs/terraform.yml

# Check if file is in Git
git ls-files buildspecs

# Check if file is on GitHub
# Go to: https://github.com/DogiparthiAasrith/react-amplify-terraform/tree/main/buildspecs

# Check Terraform state
cd terraform
terraform show | Select-String "buildspec"
```

## Summary

The fix is simple: **Run `terraform apply` in the terraform directory**. This will update the CodeBuild projects in AWS to use the correct buildspec path.

---

**After completing these steps, your pipeline will work correctly!**
