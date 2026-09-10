# AWS EKS 기반 CNAPP 프로젝트

AWS EKS 위에서 SentinelOne(Runtime Detection), CI/CD 보안 게이트(Image/IaC Scan), Attack Path 탐지(CSPM·CIEM)를 구현하는 캡스톤 프로젝트입니다. Terraform으로 인프라를 코드화(IaC)하고, GitHub Actions로 CI를, Argo CD(GitOps)로 CD를 구성합니다.

## 프로젝트 관리

- Jira: [CNAPP PROJECT (KAN)](https://awsekscnappproject.atlassian.net/browse/KAN) — Epic/Task 및 일정 관리
- 브랜치·커밋 규칙: `feature/KAN-12-설명`, `fix/KAN-34-설명` 형식으로 이슈 키 포함 (자세한 내용은 KAN-13 참고)

## 폴더 구조

```
.
├── .github/workflows/       # GitHub Actions CI 파이프라인 (ci.yml 등)
├── terraform/
│   ├── modules/
│   │   ├── vpc/             # VPC, Subnet, NAT Gateway
│   │   ├── eks/              # EKS Cluster, Node Group
│   │   └── iam/               # IAM Role, IRSA 정책
│   └── environments/
│       └── dev/               # 실제 apply 대상 (모듈 조합)
├── k8s/
│   ├── apps/                  # DVWA, SentinelOne Agent 등 워크로드 매니페스트 (Argo CD가 watch)
│   └── argocd/                 # Argo CD Application/AppProject 정의
├── scripts/
│   └── attack-scenarios/       # 시나리오 A(Pod Identity 과다권한), 시나리오 B(Node Credential 탈취) 실행 스크립트
└── docs/
    └── architecture-diagram.png   # 전체 아키텍처 구성도
```

## 아키텍처 개요

전체 구성도는 [`docs/architecture-diagram.png`](docs/architecture-diagram.png)를 참고하세요.

- **인프라**: VPC(Public/Private Subnet, Multi-AZ) + EKS Cluster + Worker Node Group
- **CI**: GitHub Actions → Docker Build → Image/IaC Scan → CI Security Gate(Critical·High 차단) → ECR Push
- **CD**: Argo CD(GitOps)가 `k8s/` 매니페스트를 watch하여 EKS에 자동 동기화
- **IaC 배포**: Terraform → IaC Scan → CI Security Gate(PASS) → `terraform apply` → EKS/VPC 프로비저닝
- **Runtime Detection**: SentinelOne Agent(DaemonSet) + CloudTrail/GuardDuty/VPC Flow Logs → CNAPP 분석엔진 → Dashboard/Grafana
- **Attack Path 시나리오**
  - 시나리오 A: Pod Identity 과다권한 (App Pod → ServiceAccount → IRSA → 과다 권한 IAM Role → S3 Bucket)
  - 시나리오 B: Node Credential 탈취 (DVWA Pod → SSRF → IMDS → Worker Node IAM Role)

## 시작하기

```bash
git clone git@github.com:<계정>/aws-eks-cnapp-project.git
cd aws-eks-cnapp-project
```

Terraform 실행, CI 파이프라인, Argo CD 설정 등 세부 사용법은 각 폴더가 채워지는 대로 이 README에 추가해나갈 예정입니다.

## 팀

- 팀원 3인 (비전공자 캡스톤 프로젝트)
