# AWS EKS 기반 CNAPP 프로젝트

AWS EKS 기반 클라우드 네이티브 환경에서 **침해 경로 탐지**, **런타임 위협 탐지**, **CI/CD 보안 게이트**를 구현하는 캡스톤 프로젝트입니다.

Terraform을 사용해 AWS 인프라를 코드화(IaC)하고, Argo CD 기반 GitOps 배포 환경을 구성합니다.  
GitHub Actions 기반 CI 보안 파이프라인은 후속 단계에서 연결할 예정입니다.

---

## 프로젝트 목표

- AWS EKS 기반 클라우드 네이티브 환경 구축
- Terraform을 활용한 VPC / IAM / EKS 인프라 코드화
- AWS Load Balancer Controller를 활용한 ALB 자동 생성 및 Ingress 연동
- SentinelOne 기반 Runtime Detection
- CloudTrail / S3 Data Event / EKS Audit Log / VPC Flow Logs 기반 행위 추적
- 공격 시나리오를 통한 IAM 권한 및 침해 경로 검증
- Critical / High 보안 이슈에 대한 배포 차단 및 알림 체계 구현

---

## 프로젝트 관리

프로젝트 일정과 작업 기록은 Notion을 기준으로 관리합니다.

GitHub에서는 코드 협업을 위해 다음 브랜치 규칙을 사용합니다.

```text
main
feature/vpc
feature/iam
feature/eks
```

- `main`: 최종 통합 브랜치
- `feature/vpc`: VPC / Subnet / NAT Gateway / Route Table 작업
- `feature/iam`: EKS / Node / IRSA / AWS Load Balancer Controller IAM 작업
- `feature/eks`: EKS Cluster / Managed Node Group / Load Balancer Controller / Ingress 작업

Commit Message 예시:

```text
feat: add vpc module
feat: add eks node group
feat: add lbc iam policy
fix: correct subnet route
docs: update terraform guide
chore: update gitignore
```

---

## 폴더 구조

```text
.
├── setup-project.ps1
│
├── terraform/
│   ├── modules/
│   │   ├── vpc/                 # VPC, Subnet, IGW, NAT Gateway, Route Table
│   │   ├── iam/                 # EKS Role, Node Role, IRSA, LBC IAM
│   │   └── eks/                 # EKS Cluster, Managed Node Group, LBC, Ingress
│   │
│   └── environments/
│       └── dev/                 # 실제 Terraform 실행 및 Module 조합
│
├── k8s/
│   ├── apps/
│   │   ├── normal-app/          # Normal App Deployment / Service / Ingress
│   │   ├── dvwa/                # DVWA Deployment / Service / Ingress
│   │   └── sentinelone/         # SentinelOne Agent DaemonSet
│   │
│   └── argocd/
│       ├── applications/        # Argo CD Application
│       └── projects/            # Argo CD AppProject
│
├── scripts/
│   └── attack-scenarios/
│       ├── scenario-a/          # Pod → ServiceAccount → IRSA → IAM Role → Decoy S3
│       └── scenario-b/          # DVWA Command Injection → IMDS → Node IAM Role → Decoy S3
│
├── docs/
│   └── architecture-diagram.png
│
├── .gitignore
└── README.md
```

> 현재 단계에서는 `.github/workflows/`를 포함하지 않습니다.  
> GitHub Actions 기반 Terraform / Image / IaC 보안 검사는 후속 CI 단계에서 추가합니다.

---

## Terraform 구조

Terraform은 **재사용 가능한 Module**과 **실제 적용 Environment**를 분리합니다.

```text
terraform/modules/vpc ─┐
terraform/modules/iam ─┼─→ terraform/environments/dev
terraform/modules/eks ─┘
                           ↓
                    terraform plan/apply
```

### Module 역할

| Module | 주요 역할 |
|---|---|
| `vpc` | VPC, Public/Private Subnet, IGW, NAT Gateway, Route Table, Subnet Tag |
| `iam` | EKS Cluster Role, Node Role, IRSA, AWS Load Balancer Controller IAM Role/Policy |
| `eks` | EKS Cluster, Managed Node Group, OIDC/IRSA 연동, AWS Load Balancer Controller, Service, Ingress |

EKS Managed Node Group이 생성하는 Auto Scaling Group은 AWS가 관리하는 정상 구성으로 유지합니다.

---

## 아키텍처 개요

전체 구성도는 `docs/architecture-diagram.png`에서 관리합니다.

### 인프라

- Region: `us-east-1`
- VPC: `10.0.0.0/16`
- Multi-AZ: `us-east-1a`, `us-east-1b`
- Public Subnet 2개
- Private Subnet 2개
- EKS Worker Node는 Private Subnet에 배치
- RDS / ECR / S3 사용

### 외부 트래픽

AWS Load Balancer Controller가 Kubernetes Ingress를 감시하고 ALB 관련 리소스를 자동 생성합니다.

```text
Internet
  ↓
ALB
  ↓
Target Group
  ↓
Pod IP
  ↓
Application
```

기본 Target Type은 `ip`를 사용합니다.

---

## CI / CD

### CI

GitHub Actions 기반 CI는 후속 단계에서 연결합니다.

예정 기능:

- Terraform Format / Validate
- Terraform IaC Security Scan
- Container Image Vulnerability Scan
- Critical / High 발견 시 배포 차단
- 통과한 Image를 ECR에 Push

### CD

Argo CD가 GitHub의 `k8s/` 경로를 감시하고 EKS에 자동 동기화합니다.

```text
GitHub
  ↓
Argo CD
  ↓
EKS
```

배포 대상:

- Normal App
- DVWA
- SentinelOne Agent

---

## Runtime Detection 및 로그

다음 로그와 보안 데이터를 수집하여 공격 성공 여부와 탐지 여부를 검증합니다.

- CloudTrail
- S3 Data Event
- EKS Audit Log
- VPC Flow Logs
- SentinelOne Runtime Detection

분석 결과는 다음 기준으로 구분합니다.

```text
공격 성공 여부
로그 존재 여부
보안 경보 여부
```

Critical / High 수준의 Runtime 위협은 Slack 알림 대상으로 구성할 예정입니다.

---

## Attack Path 시나리오

### Scenario A — IRSA 과다 권한

```text
Compromised Pod
  ↓
ServiceAccount
  ↓
IRSA
  ↓
IAM Role
  ↓
Decoy S3
```

Pod가 ServiceAccount와 IRSA를 통해 과도한 IAM 권한을 획득하고 Decoy S3에 접근할 수 있는지 검증합니다.

### Scenario B — Node Credential 탈취

```text
DVWA
  ↓
Command Injection
  ↓
Pod 내부 명령 실행
  ↓
IMDS
  ↓
Node IAM Role
  ↓
Decoy S3
```

DVWA Command Injection을 통해 Pod 내부에서 IMDS에 접근하고 Worker Node IAM Role Credential을 사용할 수 있는지 검증합니다.

---

## 시작하기

### 1. Terraform 설치

Windows 환경에서는 HashiCorp 공식 설치 페이지에서 Terraform을 설치합니다.

https://developer.hashicorp.com/terraform/install

설치 확인:

```powershell
terraform -version
```

### 2. Repository Clone

```powershell
git clone https://github.com/Halee0090/aws-eks-cnapp-project.git
cd aws-eks-cnapp-project
```

### 3. 기본 프로젝트 구조 생성

필요한 경우 Repository Root에서 다음 스크립트를 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-project.ps1
```

### 4. Terraform 실행

```powershell
cd terraform\environments\dev

terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

`terraform plan` 결과에서 예상하지 않은 삭제 또는 변경이 없는지 확인한 뒤 `apply`를 진행합니다.

---

## GitHub 협업 흐름

```text
main 최신화
    ↓
feature Branch 생성
    ↓
담당 Module 작업
    ↓
terraform fmt / validate / plan
    ↓
Commit
    ↓
Push
    ↓
Pull Request
    ↓
Code Review
    ↓
main Merge
```

팀원은 가능한 한 자신의 Module 디렉터리를 중심으로 수정합니다.

```text
feature/vpc → terraform/modules/vpc/
feature/iam → terraform/modules/iam/
feature/eks → terraform/modules/eks/
```

`terraform/environments/dev/main.tf`와 같이 여러 Module이 만나는 파일은 충돌을 줄이기 위해 최종 통합 단계에서 수정합니다.

---

## 주의사항

다음 정보는 GitHub에 Commit하지 않습니다.

```text
terraform.tfvars
*.tfstate
*.tfstate.*
.terraform/
AWS Access Key
AWS Secret Access Key
Password
Token
Private Key
```

실제 `terraform.tfvars` 대신 `terraform.tfvars.example`을 Repository에서 공유합니다.

---

## 팀

- 팀원 3인
- 역할
  - 네트워크 엔지니어
  - 보안 엔지니어
  - 클라우드 보안 엔지니어
