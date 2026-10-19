# Scenario B IRSA Role & Policy (IMDSv1 우회 방어 및 최소 권한 IRSA)

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