# Namespace configuration
variable "namespace" {
  description = "Kubernetes namespace for Actions Runner Controller"
  type        = string
  default     = "arc-system"
}

variable "create_namespace" {
  description = "Whether to create a new namespace for ARC"
  type        = bool
  default     = true
}

# Authentication configuration
variable "github_token" {
  description = "GitHub Personal Access Token with appropriate permissions"
  type        = string
  sensitive   = true
}

# Helm chart configuration
variable "helm_chart_version" {
  description = "Version of the ARC Helm chart"
  type        = string
  default     = "0.23.5"
}

variable "helm_values" {
  description = "Additional Helm values for ARC chart (in YAML format)"
  type        = string
  default     = ""
}

variable "cert_manager_version" {
  description = "Version of cert-manager Helm chart"
  type        = string
  default     = "v1.12.0"
}

variable "cert_manager_values" {
  description = "Values for cert-manager Helm chart"
  type        = string
  default     = ""
}

# Node architecture configuration
variable "add_arch_tolerations" {
  description = "Whether to add architecture-specific tolerations to pods"
  type        = bool
  default     = false
}

variable "node_architecture" {
  description = "Node architecture (amd64 or arm64)"
  type        = string
  default     = "amd64"
  validation {
    condition     = contains(["amd64", "arm64"], var.node_architecture)
    error_message = "The node_architecture must be either amd64 or arm64."
  }
}

# Runner configuration
variable "runner_deployments" {
  description = "List of runner deployment configurations"
  type = list(object({
    name       = string
    repository = string
    replicas   = number
    labels     = list(string)
    env = list(object({
      name  = string
      value = string
    }))
    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
  }))
  default = []
}

variable "runner_autoscalers" {
  description = "List of runner autoscaler configurations"
  type = list(object({
    name              = string
    target_deployment = string
    min_replicas      = number
    max_replicas      = number
    metrics           = list(map(any))
  }))
  default = []
}

# Kubernetes configuration
variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_config_context" {
  description = "Context to use from the kubeconfig file"
  type        = string
  default     = ""
}
