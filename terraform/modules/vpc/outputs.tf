# ─────────────────────────────────────────────
# VPC Module 출력값 → EKS Module 등이 사용
# ─────────────────────────────────────────────

output "vpc_id" {
  value = aws_vpc.cnapp.id
}

output "public_subnet_ids" {
  description = "ALB 배치용 (kubernetes.io/role/elb 태그)"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "EKS Worker Node 배치용 (kubernetes.io/role/internal-elb 태그)"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "nat_gateway_ids" {
  description = "NAT Gateway ID 목록 [NAT-a, NAT-b]"
  value = [
    aws_nat_gateway.nat_a.id,
    aws_nat_gateway.nat_b.id
  ]
}
