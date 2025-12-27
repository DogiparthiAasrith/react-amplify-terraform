# IAM Role for Amplify Service (separate from OIDC role)
resource "aws_iam_role" "amplify_service_role" {
  name = "${var.project_name}-amplify-service-role"

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

  tags = {
    Name        = "${var.project_name}-amplify-service-role"
    Environment = var.environment
  }
}

# IAM Policy for Amplify Service Role - Using AWS Managed Policy
resource "aws_iam_role_policy_attachment" "amplify_admin" {
  role       = aws_iam_role.amplify_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# Wait for IAM role to propagate
resource "time_sleep" "wait_for_iam" {
  depends_on      = [aws_iam_role_policy_attachment.amplify_admin]
  create_duration = "15s"
}

# AWS Amplify App
resource "aws_amplify_app" "react_app" {
  name       = var.project_name
  repository = var.repository_url

  access_token         = var.github_access_token
  iam_service_role_arn = aws_iam_role.amplify_service_role.arn

  depends_on = [time_sleep.wait_for_iam]

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
