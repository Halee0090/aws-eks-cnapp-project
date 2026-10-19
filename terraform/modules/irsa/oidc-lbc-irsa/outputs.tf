output "role_arn" {
  value       = module.lbc_irsa.arn
  description = "ARN of IAM role for AWS Load Balancer Controller"
}

output "policy_arn" {
  value       = aws_iam_policy.lbc.arn
  description = "ARN of IAM policy for AWS Load Balancer Controller"
}