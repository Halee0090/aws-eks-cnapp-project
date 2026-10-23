module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name

}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  prefix       = var.project_name
  cluster_name = "${var.project_name}-eks"

  cluster_subnet_ids = concat(
    module.vpc.public_subnet_ids,
    module.vpc.private_subnet_ids
  )

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn
}

module "irsa" {
  source = "../../modules/irsa/oidc-lbc-irsa"

  project_name        = var.project_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  decoy_s3_bucket_arn = module.decoy_s3.s3_bucket_arn
}