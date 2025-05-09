# Terraform GitHub Actions Runner Controller (ARC) Module

This Terraform module deploys the [GitHub Actions Runner Controller](https://github.com/actions/actions-runner-controller) on a Kubernetes cluster, including all necessary dependencies.

## Features

- Uses the latest ARC 0.11.0 with Autoscaling Runner Scale Sets mode
- Optional cert-manager deployment (no longer required with ARC 0.11.0+)
- Configures GitHub token or GitHub App authentication
- Supports custom runner scale sets with built-in autoscaling
- Cross-architecture support (amd64/arm64)
- Customizable namespace and configuration

## Usage

```hcl
# Configure providers in your root module
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "my-context"
  }
}

module "arc" {
  source = "github.com/idvoretskyi/Terraform-ARC-cluster"
  
  # Authentication - use either GitHub PAT
  github_token = "ghp_your_github_token"
  
  # OR GitHub App authentication
  # github_app_auth = {
  #   app_id          = "123456"
  #   installation_id = "12345678"
  #   private_key     = file("${path.module}/github-app-key.pem")
  # }
  
  # Optional: Configure runner scale sets
  runner_deployments = [
    {
      name       = "runner-scale-set"
      repository = "my-org/my-repo"
      replicas   = 5  # Maximum number of runners
      labels     = ["self-hosted", "linux", "x64"]
      env = [
        {
          name  = "RUNNER_WORKDIR"
          value = "/home/runner/work"
        }
      ]
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "250m"
          memory = "256Mi"
        }
      }
    }
  ]
  
  # Optional: Configure autoscaling parameters
  # (These will be used to set minRunners for the scale sets)
  runner_autoscalers = [
    {
      name              = "runner-autoscaler"
      target_deployment = "runner-scale-set"
      min_replicas      = 1
      max_replicas      = 5
      metrics = []  # Not used in the new architecture
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| kubernetes | >= 2.0.0 |
| helm | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | >= 2.0.0 |
| helm | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| github_token | GitHub Personal Access Token with appropriate permissions | `string` | `""` | no |
| github_app_auth | GitHub App authentication configuration (app_id, installation_id, private_key) | `object` | `null` | no |
| namespace | Kubernetes namespace for Actions Runner Controller | `string` | `"arc-system"` | no |
| create_namespace | Whether to create a new namespace for ARC | `bool` | `true` | no |
| helm_chart_version | Version of the ARC Helm chart | `string` | `"0.11.0"` | no |
| helm_values | Additional Helm values for ARC chart (in YAML format) | `string` | `""` | no |
| install_cert_manager | Whether to install cert-manager (no longer required for ARC 0.11.0+) | `bool` | `true` | no |
| cert_manager_version | Version of cert-manager Helm chart | `string` | `"v1.12.0"` | no |
| cert_manager_values | Values for cert-manager Helm chart | `string` | `""` | no |
| add_arch_tolerations | Whether to add architecture-specific tolerations to pods | `bool` | `false` | no |
| node_architecture | Node architecture (amd64 or arm64) | `string` | `"amd64"` | no |
| runner_deployments | List of runner deployment configurations | `list(object)` | `[]` | no |
| runner_autoscalers | List of runner autoscaler configurations | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | The Kubernetes namespace where ARC was deployed |
| cert_manager_release_name | The name of the cert-manager Helm release |
| arc_release_name | The name of the Actions Runner Controller Helm release |
| runner_scale_sets | The deployed runner scale sets |

## License

This module is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.

## Author

Ihor Dvoretskyi
