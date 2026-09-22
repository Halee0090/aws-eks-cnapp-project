variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "prefix" {
  description = "태그 이름"
  type        = string
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_role_arn" {
  description = "EKS 제어 영역에 부여할 IAM Role ARN"
  type        = string
}

variable "private_subnet_ids" {
  description = "EKS 클러스터 및 워커 노드가 사용할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "k8s_version" {
  description = "설치할 Kubernetes 버전"
  type        = string
  default     = "1.35"
}

variable "node_role_arn" {
  description = "EKS 워커 노드에 부여할 IAM Role ARN"
  type        = string
}

variable "node_desired_size" {
  description = "노드그룹 원하는 노드 수"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "노드그룹 최소 노드 수"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "노드그룹 최대 노드 수"
  type        = number
  default     = 3
}

variable "node_instance_types" {
  description = "워커 노드 EC2 인스턴스 타입"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "워커 노드 루트 디스크 크기(GiB)"
  type        = number
  default     = 30
}