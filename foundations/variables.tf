variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id variable must must be 6 to 30 lowercase letters, digits, or hyphens; it must start with a letter and cannot end with a hyphen."
  }
  description = <<-EOD
  The GCP project identifier where the foundational resources will be created.
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

variable "region" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2,}-[a-z]{2,}[0-9]$", var.region))
    error_message = "The region value must be a valid Google Cloud region name."
  }
  description = <<-EOD
  The Compute Engine regions in which to create the foundation resources.
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
  An optional set of key:value string pairs that will be added to the GCP resources.
  EOD
}
