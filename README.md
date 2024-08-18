# GitOps Hub Project with IaC, Flux, and GitHub

This project sets up a GitOps hub using Infrastructure as Code (IaC), Flux, GitHub, and AWS for testing purposes. It automates the deployment and management of Kubernetes clusters and applications, with Git as the single source of truth, leveraging KIND for local testing and AWS for secret storage and cloud resources.

## Overview

This project leverages the following stack:

- **OpenTofu**: For provisioning infrastructure as code.
- **Flux**: To enable continuous deployment of Kubernetes manifests from Git.
- **GitHub**: Serves as the GitOps repository to store Kubernetes manifests and Terraform configurations.
- **Kind**: Used for creating and managing local Kubernetes clusters for testing.
- **AWS**: Utilized for storing secrets and managing additional cloud resources to support the Kubernetes environment.

## Setup

Follow these steps to set up the environment (e.g. Ubuntu 22.04):


1. Set up Docker  
    <details>
    <summary>details</summary>

    * Install necessary packages:
        ```bash
        sudo apt-get install build-essential docker.io -y
        ```

    * Add your user to the Docker group:
        ```bash
        sudo usermod -aG docker ${USER}
        su - ${USER}
        ```

    * Verify Docker installation:
        ```bash
        docker ps
        ```

    </details>

2. Install Homebrew and necessary tools:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    yes | brew install opentofu fluxcd/tap/flux htop kind kubectl
    ```

3. Export Project environment variables:
    ```bash
    export TF_VAR_github_org="your_github_org"                    # Your GitHub organization name
    export TF_VAR_github_repository="your_github_repo"            # Name of the GitHub repository to be created
    export TF_VAR_github_token="your_github_token"                # Personal access token for GitHub with repository permissions
    export TF_VAR_aws_access_key_id="your_aws_access_key_id"      # AWS Access Key ID for authentication
    export TF_VAR_secret_access_key="your_secret_access_key"      # AWS Secret Access Key for authentication
    ```

4. Initialize and apply Terraform configuration:
    ```bash
    cd tf-flux-kind-github
    tofu init
    tofu plan
    tofu apply
    ```


## Retrieve and Decode a Terraform Plan or State File from a Kubernetes Secret

To get a gzipped plan or state file from a Kubernetes secret, run:

```bash
kubectl get secret tfplan-default-project-1-dev -n flux-system -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.value)"' | base64 -d > ~/plan-or-state-file.gz
```

You can then unzip the file using:

```bash
gunzip ~/plan-or-state-file.gz
```