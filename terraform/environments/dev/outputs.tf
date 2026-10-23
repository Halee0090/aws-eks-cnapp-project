output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}


output "decoy_s3_bucket_name" {
  description = "Decoy S3 Bucket 이름"
  value       = module.decoy_s3.s3_bucket_id
}

output "decoy_s3_bucket_arn" {
  description = "Decoy S3 Bucket ARN"
  value       = module.decoy_s3.s3_bucket_arn
}

output "decoy_s3_object_key" {
  description = "Decoy 객체 Key"
  value       = aws_s3_object.decoy_file.key
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}