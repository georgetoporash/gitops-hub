terraform {
  required_version = ">= 1.5.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.3.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.2.3"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

# Create local file for environment credentials
resource "null_resource" "create_env_secret_file" {
  provisioner "local-exec" {
    command = <<EOT
      cat > ~/my-env-credentials.yaml <<EOF
      apiVersion: v1
      kind: Secret
      metadata:
          name: my-env-credentials
          namespace: flux-system
      type: Opaque
      stringData:
          AWS_ACCESS_KEY_ID: ${var.aws_access_key_id}
          AWS_SECRET_ACCESS_KEY: ${var.aws_secret_access_key}
          AWS_REGION: us-east-1
    EOT
  }
}

# Define a Kubernetes cluster using kind
resource "kind_cluster" "this" {
  name = "hub-cluster"
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    node {
      role = "control-plane"
    }
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}

# Create a GitHub repository
resource "github_repository" "this" {
  depends_on = [kind_cluster.this]

  name        = var.github_repository
  description = var.github_repository
  visibility  = "private"
  auto_init   = true

  vulnerability_alerts = true
}

# Bootstrap Flux in the GitHub repository
resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]

  embedded_manifests = true
  path               = "clusters/gitops-hub-manage"
}

# Create a file in the GitHub repository for Flux HelmRepository
resource "github_repository_file" "tf-controllerHelmRepository" {
  depends_on = [flux_bootstrap_git.this]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/flux-manifests/tf-controllerHelmRepository.yaml"
  content             = file("./flux-manifests/tf-controllerHelmRepository.yaml")
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Apply Kubernetes secret using local-exec provisioner
resource "null_resource" "apply_env_secret" {
  depends_on = [github_repository_file.tf-controllerHelmRepository]

  provisioner "local-exec" {
    command = <<EOT
      while true; do
        secret=$(kubectl apply -f ~/my-env-credentials.yaml)
        secret_state=$(kubectl get secret my-env-credentials -n flux-system -o jsonpath='{.metadata.name}')
        if [ ! -z "$secret_state" ]; then
          echo "Secret is available: $tf"
          exit 0
        else
          echo "Waiting for my-env-credentials secret to be available..."
          sleep 10
        fi
      done
    EOT
  }
}

# Wait for tf-controller deployment to be available
resource "null_resource" "wait_for_deployment_tf_controller" {
  depends_on = [null_resource.apply_env_secret]

  provisioner "local-exec" {
    command = <<EOT
      while true; do
        tf=$(kubectl get deployment tf-controller -n flux-system -o jsonpath='{.metadata.name}')
        if [ ! -z "$tf" ]; then
          echo "Deployment is available: $tf"
          exit 0
        else
          echo "Waiting for tf-controller deployment to be available..."
          sleep 10
        fi
      done
    EOT
  }
}

# Create GitHub repository file for project-1-dev
resource "github_repository_file" "project-1-dev" {
  depends_on = [null_resource.wait_for_deployment_tf_controller]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/flux-manifests/tf-project-1-dev.yaml"
  content             = file("./flux-manifests/tf-project-1-dev.yaml")
  commit_message      = "Add terraform controller project-1-dev.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Create GitHub repository file for project-2-dev
resource "github_repository_file" "project-2-dev" {
  depends_on = [null_resource.wait_for_deployment_tf_controller]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/flux-manifests/tf-project-2-dev.yaml"
  content             = file("./flux-manifests/tf-project-2-dev.yaml")
  commit_message      = "Add terraform controller project-2-dev.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Create GitHub repository file for project-1-prod
resource "github_repository_file" "project-1-prod" {
  depends_on = [null_resource.wait_for_deployment_tf_controller]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/flux-manifests/tf-project-1-prod.yaml"
  content             = file("./flux-manifests/tf-project-1-prod.yaml")
  commit_message      = "Add terraform controller project-1-prod.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Create GitHub repository file for project-2-prod
resource "github_repository_file" "project-2-prod" {
  depends_on = [null_resource.wait_for_deployment_tf_controller]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/flux-manifests/tf-project-2-prod.yaml"
  content             = file("./flux-manifests/tf-project-2-prod.yaml")
  commit_message      = "Add terraform controller project-2-prod.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Add main.tf file for project-1-dev
resource "github_repository_file" "project-1-dev-main" {
  depends_on = [github_repository_file.project-1-dev]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/tf-projects/project-1-dev/main.tf"
  content             = file("./tf-projects/project-1-dev/main.tf")
  commit_message      = "Add terraform code for project-1-dev.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Add main.tf file for project-2-dev
resource "github_repository_file" "project-2-dev-main" {
  depends_on = [github_repository_file.project-2-dev]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/tf-projects/project-2-dev/main.tf"
  content             = file("./tf-projects/project-2-dev/main.tf")
  commit_message      = "Add terraform code for project-2-dev.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Add main.tf file for project-1-prod
resource "github_repository_file" "project-1-prod-main" {
  depends_on = [github_repository_file.project-1-prod]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/tf-projects/project-1-prod/main.tf"
  content             = file("./tf-projects/project-1-prod/main.tf")
  commit_message      = "Add terraform code for project-1-prod.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

# Add main.tf file for project-2-prod
resource "github_repository_file" "project-2-prod-main" {
  depends_on = [github_repository_file.project-2-prod]

  repository          = github_repository.this.name
  branch              = "main"
  file                = "clusters/gitops-hub-manage/tf-projects/project-2-prod/main.tf"
  content             = file("./tf-projects/project-2-prod/main.tf")
  commit_message      = "Add terraform code for project-2-prod.yaml"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}
