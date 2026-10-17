# STEP 1. EKS Cluster Role 생성

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.project_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name    = "${var.project_name}-eks-cluster-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# STEP 2. EKS Worker Node Role 생성 (시나리오 B IMDSv1 공격 대상)

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.project_name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = {
    Name    = "${var.project_name}-eks-node-role"
    Project = var.project_name
  }
}

# 1. EKS Worker Node Policy
resource "aws_iam_role_policy_attachment" "eks_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# 2. EKS CNI Policy
resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# 3. ECR Read Only Policy
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 4. SSM Managed Instance Core Policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# STEP 3. AWS Load Balancer Controller IRSA Role

module "lbc_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.8"

  name = "${var.project_name}-lbc-role"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    this = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }
}


# STEP 4. Scenario A IRSA Role & Policy (Decoy S3 접근 권한 실증용)

resource "aws_iam_policy" "scenario_a_s3" {
  name = "${var.project_name}-scenario-a-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          var.decoy_s3_bucket_arn,
          "${var.decoy_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

module "scenario_a_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.8"

  name = "${var.project_name}-scenario-a-role"

  oidc_providers = {
    this = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "default:scenario-a-sa"
      ]
    }
  }

  policies = {
    decoy_s3 = aws_iam_policy.scenario_a_s3.arn
  }
}


# STEP 5. Scenario B IRSA Role & Policy (IMDSv1 우회 방어 및 최소 권한 IRSA)

resource "aws_iam_policy" "scenario_b_s3" {
  name = "${var.project_name}-scenario-b-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          var.decoy_s3_bucket_arn,
          "${var.decoy_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

module "scenario_b_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.8"

  name = "${var.project_name}-scenario-b-role"

  oidc_providers = {
    this = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "default:scenario-b-sa"
      ]
    }
  }

  policies = {
    scenario_b_s3 = aws_iam_policy.scenario_b_s3.arn
  }
}