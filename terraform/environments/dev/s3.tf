# Decoy S3 Bucket
module "decoy_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  # S3 Bucket 이름은 전 세계에서 고유해야 하므로
  # 접미사를 자동 생성하도록 prefix 사용
  bucket_prefix = "${var.project_name}-decoy-"

  # 실습 환경에서 객체가 있어도 destroy 가능
  force_destroy = true

  # ACL 비활성화 및 Bucket 소유권 강제
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  # 외부 공개 차단
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # 객체 버전 관리
  versioning = {
    enabled = true
  }

  # 프로젝트에서 KMS를 제외했으므로 SSE-S3 사용
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-decoy-s3"
    Project     = var.project_name
    Environment = "dev"
    Purpose     = "cnapp-attack-scenario"
  }
}

# 공격 시나리오에서 접근할 가짜 객체
resource "aws_s3_object" "decoy_file" {
  bucket = module.decoy_s3.s3_bucket_id
  key    = "decoy/confidential-data.txt"

  content = <<-EOT
    AWS CNAPP Project - Training Decoy File
    This file contains no real credentials or customer data.
    Access to this object is monitored through CloudTrail S3 Data Events.
  EOT

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  tags = {
    Project = var.project_name
    Purpose = "decoy"
  }
}