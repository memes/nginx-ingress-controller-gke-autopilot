variable "repo" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2,}(?:-[a-z]+[1-9])?-docker.pkg.dev/[^/]+/[^/]+", var.repo))
    error_message = "The repo value must be a valid arifact repository."
  }
  description = <<-EOD
  The generated service account will be given read-only access role to the repo.
  EOD
}

variable "kustomization_path" {
  type        = string
  default     = ""
  description = <<-EOD
  The path that will be used for a generated kustomizations; if left blank (default)
  the kustomization files will be written to '../generated/'.
  EOD
}

variable "annotations" {
  type = map(string)
  validation {
    # Kubernetes annotations must have keys are [prefix/]name, where name is a
    # valid DNS label, and prefix is a valid DNS domain with <= 253 characters.
    # Values are not restricted; total combined of all keys and values <= 256Kb
    # which is not a feasible Terraform validation rule.
    condition     = var.annotations == null ? true : length(compact([for k, v in var.annotations : can(regex("^(?:(?:[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\\.)+[a-zA-Z]{2,63}/)?[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", k)) && can(regex("^(?:[^/]{1,253}/)?[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", k)) ? "x" : ""])) == length(keys(var.annotations))
    error_message = "Each annotation key:value pair must match expectations."
  }
  default     = {}
  description = <<-EOD
  An optional set of key:value string pairs that will be added generated resources
  that accept kubernetes style annotations.
  EOD
}
