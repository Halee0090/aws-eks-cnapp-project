output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "lbc_role_arn" {
  value = module.lbc_irsa.arn
}

output "scenario_a_role_arn" {
  value = module.scenario_a_irsa.arn
}