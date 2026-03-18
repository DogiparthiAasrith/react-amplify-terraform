output "app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.react_app.id
}

output "app_arn" {
  description = "Amplify App ARN"
  value       = aws_amplify_app.react_app.arn
}

output "default_domain" {
  description = "Amplify default domain"
  value       = aws_amplify_app.react_app.default_domain
}

output "branch_name" {
  description = "Amplify branch name"
  value       = aws_amplify_branch.main.branch_name
}

output "branch_url" {
  description = "URL for the Amplify branch"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.react_app.default_domain}"
}
