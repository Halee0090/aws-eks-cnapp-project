variable "project_name" {
  type        = string
  description = "Project name"
  default     = "awscnappeks"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN for EKS Cluster"
}

variable "decoy_s3_bucket_arn" {
  description = "Decoy S3 Bucket ARN"
  type        = string
}