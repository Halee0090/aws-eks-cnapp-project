variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC Provider ARN"
  default     = null
}

variable "decoy_s3_bucket_arn" {
  type        = string
  description = "Decoy S3 Bucket ARN"
  default     = null
}