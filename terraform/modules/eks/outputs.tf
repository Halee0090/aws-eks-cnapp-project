output "cluster_name" {
  description = "생성된 EKS 클러스터 이름"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API 서버 엔드포인트"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "클러스터 인증서 데이터 (kubectl 접속용)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer_url" {
  description = "EKS OIDC Issuer URL"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}