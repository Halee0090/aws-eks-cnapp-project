# VPC Module

AWS CNAPP 프로젝트 기본 네트워크를 생성한다.

## 생성 리소스 (17개)

| 리소스 | 개수 | 내용 |
|---|---|---|
| aws_vpc | 1 | 10.0.0.0/16, DNS 지원·호스트 이름 활성화 |
| aws_subnet | 4 | public-a/b (10.0.0.0/24, 10.0.1.0/24), private-a/b (10.0.10.0/24, 10.0.11.0/24) |
| aws_internet_gateway | 1 | Public Subnet 인터넷 출입구 |
| aws_eip | 2 | NAT Gateway 공인 IP |
| aws_nat_gateway | 2 | NAT-a (public-a), NAT-b (public-b) |
| aws_route_table | 3 | public(→IGW), private-a(→NAT-a), private-b(→NAT-b) |
| aws_route_table_association | 4 | 서브넷 4개 연결 |

## Subnet Tag (AWS Load Balancer Controller용)

| 서브넷 | 태그 |
|---|---|
| public-a, public-b | kubernetes.io/role/elb = 1 |
| private-a, private-b | kubernetes.io/role/internal-elb = 1 |

## 입력값

| 변수 | 필수 | 기본값 |
|---|---|---|
| project_name | O | - |
| vpc_cidr | O | - |
| az_a / az_b | | us-east-1a / us-east-1b |
| public_subnet_a_cidr / public_subnet_b_cidr | | 10.0.0.0/24 / 10.0.1.0/24 |
| private_subnet_a_cidr / private_subnet_b_cidr | | 10.0.10.0/24 / 10.0.11.0/24 |

## 출력값

| 출력값 | 사용처 |
|---|---|
| vpc_id | EKS |
| public_subnet_ids | EKS (ALB / Load Balancer Controller) |
| private_subnet_ids | EKS (Worker Node) |
| nat_gateway_ids | 참고용 [NAT-a, NAT-b] |

## 비용 주의

NAT Gateway 2개와 Elastic IP 2개는 생성 시점부터 시간당 과금된다. 실습이 끝나면 팀과 협의해 정리한다.
