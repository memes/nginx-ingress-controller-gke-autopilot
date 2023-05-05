variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
  The GCP project identifier where the Autopilot GKE cluster will be created.
  EOD
}

variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.name))
    error_message = "The name variable must be RFC1035 compliant and between 1 and 63 characters in length."
  }
  description = <<-EOD
  The name to use when naming resources managed by this module. Must be RFC1035
  compliant and between 1 and 63 characters in length, inclusive.
  EOD
}

variable "repo" {
  type = string
  # validation {
  #   condition     = can(regex("^[a-z]{2,}(?:-[a-z]+[1-9])?-docker.pkg.dev/[^/]+/[^/]+)", var.repo))
  #   error_message = "The repo value must be a valid arifact repository."
  # }
  description = <<-EOD
  The generated service account will be given read-only access role to the repo.
  EOD
}

variable "subnet" {
  type = object({
    self_link           = string
    pods_range_name     = string
    services_range_name = string
    master_cidr         = string
  })
  validation {
    condition     = var.subnet == null ? false : can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", var.subnet.self_link)) && coalesce(var.subnet.pods_range_name, "unspecified") != "unspecified" && coalesce(var.subnet.services_range_name, "unspecified") != "unspecified" && can(cidrhost(var.subnet.master_cidr, 1))
    error_message = "The subnet value must have a valid self_link URI, and non-empty pods and services names, and a valid master CIDR."
  }
  description = <<-EOD
  Provides the subnet self_link to which the cluster will be attached, the
  *names* of the secondary ranges to use for pods and services, and the CIDR to
  use for masters.
  EOD
}

variable "master_authorized_networks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  validation {
    condition     = var.master_authorized_networks == null ? false : length(compact([for v in var.master_authorized_networks : can(cidrhost(v.cidr_block, 0)) && coalesce(v.display_name, "unspecified") != "unspecified" ? "x" : ""])) == length(var.master_authorized_networks)
    error_message = "Each master_authorized_networks value must have a valid cidr_block and display_name."
  }
  description = <<-EOD
  A set of CIDRs that are permitted to reach the kubernetes API endpoints.
  EOD
}

variable "labels" {
  type = map(string)
  validation {
    # GCP resource labels must be lowercase alphanumeric, underscore or hyphen,
    # and the key must be <= 63 characters in length
    condition     = length(compact([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v)) ? "x" : ""])) == length(keys(var.labels))
    error_message = "Each label key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional set of key:value string pairs that will be added to the Autopilot
  resources.
  EOD
}

variable "kubeconfig_path" {
  type        = string
  default     = ""
  description = <<-EOD
  The path that will be used for a generated kubeconfig; if left blank (default)
  the kubeconfig will be written to '../generated/kubeconfig'.
  EOD
}
