# IAM Role for Amplify Service
resource "aws_iam_role" "amplify_service_role" {
  name = "${var.project_name}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS managed policy for Amplify
resource "aws_iam_role_policy_attachment" "amplify_policy" {
  role       = aws_iam_role.amplify_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# AWS Amplify App
resource "aws_amplify_app" "react_app" {
  name       = var.project_name
  repository = var.repository_url

  # GitHub personal access token
  access_token = var.github_access_token

  # Service role for Amplify
  iam_service_role_arn = aws_iam_role.amplify_service_role.arn

  # Build settings for React app
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - cd frontend
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: frontend/build
        files:
          - '**/*'
      cache:
        paths:
          - frontend/node_modules/**/*
  EOT

  # Environment variables
  environment_variables = {
    ENV = var.environment
  }

  # Enable auto branch creation
  enable_auto_branch_creation = false
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true

  # Custom rules for SPA routing
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }

  depends_on = [aws_iam_role_policy_attachment.amplify_policy]
}

# Amplify Branch
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.react_app.id
  branch_name = var.branch_name

  framework = "React"
  stage     = var.environment == "prod" ? "PRODUCTION" : "DEVELOPMENT"

  enable_auto_build = true

  environment_variables = {
    REACT_APP_ENV = var.environment
  }
}
