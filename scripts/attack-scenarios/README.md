# attack-scenarios

통제된 환경에서 실행하는 공격 시나리오 스크립트입니다.

- 시나리오 A: Pod Identity 과다권한 (App Pod → ServiceAccount → IRSA → 과다 권한 IAM Role → S3 Bucket)
- 시나리오 B: Node Credential 탈취 (DVWA Pod → SSRF → IMDS → Worker Node IAM Role)

⚠️ 반드시 격리된 실습/테스트 환경에서만 실행하세요.
