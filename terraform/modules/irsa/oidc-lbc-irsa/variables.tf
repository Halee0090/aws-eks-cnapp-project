variable "project_name" {
  type        = string
  description = "Project name"
  default     = "awscnappeks"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN for EKS Cluster"
}