output "amplify_app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.react_app.id
}

output "amplify_app_arn" {
  description = "Amplify App ARN"
  value       = aws_amplify_app.react_app.arn
}

output "amplify_default_domain" {
  description = "Default domain for the Amplify app"
  value       = aws_amplify_app.react_app.default_domain
}

output "amplify_branch_url" {
  description = "URL for the deployed branch"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.react_app.default_domain}"
}

output "amplify_service_role_arn" {
  description = "IAM Role ARN for Amplify service"
  value       = aws_iam_role.amplify_service_role.arn
}
