# EKS 클러스터 리소스 정의
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.k8s_version

  # 기본 Add-on은 아래 aws_eks_addon 리소스에서 관리
  bootstrap_self_managed_addons = false

  # 클러스터 생성자 관리자 액세스 허용
  # 인증 모드: EKS API
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # EKS Control Plane ENI
  # Public Subnet 2개 + Private Subnet 2개
  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Control Plane 로그 전체 활성화
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Name    = var.cluster_name
  }
}

# Amazon VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "vpc-cni"
  addon_version = "v1.22.4-eksbuild.3"
}

# EKS 워커 노드 그룹 정의
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.prefix}-node-group"
  node_role_arn   = var.node_role_arn

  # Worker Node는 Private Subnet 2개에만 배치
  subnet_ids = var.private_subnet_ids

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = var.node_disk_size
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
    update_strategy = "DEFAULT"
  }

  node_repair_config {
    enabled = false
  }

  # VPC CNI 설치 후 Worker Node 생성
  depends_on = [
    aws_eks_addon.vpc_cni
  ]

  tags = {
    Name    = "${var.prefix}-node-group"
    Project = var.project_name
  }
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "coredns"
  addon_version = "v1.14.3-eksbuild.23"

  depends_on = [
    aws_eks_node_group.this
  ]
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "kube-proxy"
  addon_version = "v1.36.0-eksbuild.25"

  depends_on = [
    aws_eks_node_group.this
  ]
}