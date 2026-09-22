# EKS 클러스터 리소스 정의
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name                                 # EKS 클러스터 이름
  role_arn = var.cluster_role_arn                             # EKS 제어 영역에 부여할 IAM 역할 ARN
  version  = var.k8s_version                                  # 사용할 Kubernetes 버전

  vpc_config {
    subnet_ids              = var.private_subnet_ids          # 클러스터가 사용할 프라이빗 서브넷 목록
    endpoint_private_access = true                             # 클러스터 엔드포인트를 프라이빗 서브넷에서만 접근 허용
    endpoint_public_access  = true                            # 클러스터 엔드포인트를 퍼블릭으로는 접근 불가
  }

  tags = {
    Name = var.cluster_name                                    # 리소스 이름 태그 지정
  }
}

# EKS 워커 노드 그룹 정의
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name                 # 연결할 클러스터 이름
  node_group_name = "${var.prefix}-node-group"               # 노드 그룹 이름
  node_role_arn   = var.node_role_arn                         # 워커 노드에 부여할 IAM 역할
  subnet_ids      = var.private_subnet_ids                   # 노드 그룹이 배치될 프라이빗 서브넷 목록
  instance_types  = var.node_instance_types                 # 사용할 EC2 인스턴스 타입
  capacity_type   = "ON_DEMAND"                              # 온디맨드 인스턴스 사용

  scaling_config {
    desired_size = var.node_desired_size                      # 기본 인스턴스 수
    max_size     = var.node_max_size                          # 최대 인스턴스 수
    min_size     = var.node_min_size                          # 최소 인스턴스 수
  }

  lifecycle {                                                 # 롤링 업데이트 제거(argo rollouts로 카나리 배포할 것이기 때문에)
    create_before_destroy = true
  }

  tags = {
    Name = "${var.prefix}-node-group"                         # 태그 이름 설정
  }
}