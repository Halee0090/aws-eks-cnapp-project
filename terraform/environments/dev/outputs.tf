output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}
