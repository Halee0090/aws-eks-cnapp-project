# ─────────────────────────────────────────────
# VPC Module 입력값
# project_name, vpc_cidr 만 필수. 나머지는 프로젝트 기준 기본값 사용
# (Root main.tf 의 module "vpc" 블록을 수정하지 않아도 동작)
# ─────────────────────────────────────────────

variable "project_name" {
  description = "리소스 이름 접두어 및 Project 태그"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "az_a" {
  description = "첫 번째 가용 영역"
  type        = string
  default     = "us-east-1a"
}

variable "az_b" {
  description = "두 번째 가용 영역"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_a_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "public_subnet_b_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_a_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

variable "private_subnet_b_cidr" {
  type    = string
  default = "10.0.11.0/24"
}
