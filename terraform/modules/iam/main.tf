# EKS Cluster Role / Node Role / IRSA / AWS Load Balancer Controller IAM Policy 및 Role

# STEP 2. EKS Cluster Role 생성

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
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# STEP 3. EKS Node Role 생성

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
}

resource "aws_iam_role_policy_attachment" "eks_worker" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# STEP 5. AWS Load Balancer Controller IRSA Role

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

# STEP 6. Scenario A IRSA Role & Policy

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