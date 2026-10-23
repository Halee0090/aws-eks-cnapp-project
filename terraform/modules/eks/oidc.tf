# EKS 클러스터 OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "${var.prefix}-eks-oidc"
  }
}