$folders = @(
    "terraform\modules\vpc",
    "terraform\modules\iam",
    "terraform\modules\eks",
    "terraform\environments\dev",
    "k8s\apps\normal-app",
    "k8s\apps\dvwa",
    "k8s\apps\sentinelone",
    "k8s\argocd\applications",
    "k8s\argocd\projects",
    "scripts\attack-scenarios\scenario-a",
    "scripts\attack-scenarios\scenario-b",
    "docs"
)

$files = @(
    ".gitignore",
    "README.md",
    "terraform\modules\vpc\main.tf",
    "terraform\modules\vpc\variables.tf",
    "terraform\modules\vpc\outputs.tf",
    "terraform\modules\iam\main.tf",
    "terraform\modules\iam\variables.tf",
    "terraform\modules\iam\outputs.tf",
    "terraform\modules\eks\main.tf",
    "terraform\modules\eks\variables.tf",
    "terraform\modules\eks\outputs.tf",
    "terraform\environments\dev\provider.tf",
    "terraform\environments\dev\main.tf",
    "terraform\environments\dev\variables.tf",
    "terraform\environments\dev\outputs.tf",
    "terraform\environments\dev\terraform.tfvars.example",
    "terraform\environments\dev\backend.tf",
    "k8s\apps\normal-app\deployment.yaml",
    "k8s\apps\normal-app\service.yaml",
    "k8s\apps\normal-app\ingress.yaml",
    "k8s\apps\dvwa\deployment.yaml",
    "k8s\apps\dvwa\service.yaml",
    "k8s\apps\dvwa\ingress.yaml",
    "k8s\apps\sentinelone\daemonset.yaml",
    "k8s\argocd\applications\sample-application.yaml",
    "k8s\argocd\projects\sample-project.yaml"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
}

Write-Host "AWS CNAPP project structure created."
