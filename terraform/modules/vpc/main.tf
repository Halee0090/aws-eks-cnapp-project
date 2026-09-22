# ─────────────────────────────────────────────
# modules/vpc : AWS CNAPP 프로젝트 기본 네트워크
#
#            Internet
#               │
#              IGW
#               │
#   ┌───────────┴───────────┐
#   public-a (1a)       public-b (1b)      ← ALB (Load Balancer Controller)
#     └ NAT-a             └ NAT-b
#   private-a (1a)      private-b (1b)     ← EKS Worker Node
#
# · Public Subnet  : 0.0.0.0/0 → Internet Gateway
# · Private Subnet : 0.0.0.0/0 → 같은 AZ의 NAT Gateway
#     private-a → NAT-a / private-b → NAT-b
#     한 AZ에 장애가 나도 다른 AZ의 노드는 외부 통신 유지
# · Subnet Tag : AWS Load Balancer Controller가 ALB 배치 서브넷을 찾는 데 사용
# ─────────────────────────────────────────────

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# ── VPC ─────────────────────────────────────
resource "aws_vpc" "cnapp" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # EKS 노드 등록, Private Endpoint 이름 확인에 필요

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# ── Public Subnet 2개 (ALB, NAT 배치) ──────────
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.cnapp.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${var.project_name}-public-a"
    "kubernetes.io/role/elb" = "1" # 인터넷용 ALB 배치 대상
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.cnapp.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${var.project_name}-public-b"
    "kubernetes.io/role/elb" = "1"
  })
}

# ── Private Subnet 2개 (EKS Worker Node 배치) ──
# 퍼블릭 IP 자동 할당 없음 → 노드가 인터넷에 직접 노출되지 않음
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.cnapp.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.az_a

  tags = merge(local.common_tags, {
    Name                              = "${var.project_name}-private-a"
    "kubernetes.io/role/internal-elb" = "1" # 내부용 로드밸런서 배치 대상
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.cnapp.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.az_b

  tags = merge(local.common_tags, {
    Name                              = "${var.project_name}-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# ── Internet Gateway ─────────────────────────
resource "aws_internet_gateway" "cnapp" {
  vpc_id = aws_vpc.cnapp.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# ── Public Route Table + 연결 ─────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cnapp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cnapp.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ── NAT Gateway용 Elastic IP 2개 ───────────────
resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip-a"
  })
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip-b"
  })
}

# ── NAT Gateway 2개 (AZ마다 1개, Public Subnet에 배치) ──
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.cnapp]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-a"
  })
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  depends_on = [aws_internet_gateway.cnapp]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-b"
  })
}

# ── Private Route Table 2개 + 연결 ─────────────
# 각 AZ가 자기 AZ의 NAT를 사용 → AZ 간 트래픽 요금 없음, 장애 격리
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.cnapp.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-a"
  })
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.cnapp.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-b"
  })
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
