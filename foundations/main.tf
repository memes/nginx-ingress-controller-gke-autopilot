terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.63"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3"
    }
  }
}

data "http" "my_address" {
  url = "https://checkip.amazonaws.com"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to get local IP address"
    }
  }
}

data "google_compute_zones" "zones" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

module "vpc" {
  source      = "memes/multi-region-private-network/google"
  version     = "2.0.0"
  project_id  = var.project_id
  name        = var.name
  description = format("Demo VPC network (%s)", var.name)
  regions     = [var.region]
  cidrs = {
    primary_ipv4_cidr        = "172.16.0.0/16"
    primary_ipv4_subnet_size = 24
    primary_ipv6_cidr        = null
    secondaries = {
      pods = {
        ipv4_cidr        = "10.0.0.0/9"
        ipv4_subnet_size = 16
      }
      services = {
        ipv4_cidr        = "10.128.0.0/16"
        ipv4_subnet_size = 20
      }
    }
  }
  options = {
    delete_default_routes = false
    restricted_apis       = true
    nat                   = true
    nat_tags = [
      "bastion",
    ]
    mtu          = 1460
    routing_mode = "GLOBAL"
    flow_logs    = false
    ipv6_ula     = false
    nat_logs     = false
  }
}

module "restricted_apis_dns" {
  source             = "memes/restricted-apis-dns/google"
  version            = "1.2.0"
  project_id         = var.project_id
  name               = format("%s-restricted-apis", var.name)
  labels             = var.labels
  network_self_links = [module.vpc.self_link]
  depends_on = [
    module.vpc,
  ]
}

module "bastion" {
  source                = "memes/private-bastion/google"
  version               = "2.3.5"
  project_id            = var.project_id
  prefix                = var.name
  external_ip           = false
  proxy_container_image = "ghcr.io/memes/terraform-google-private-bastion/forward-proxy:2.3.5"
  zone                  = data.google_compute_zones.zones.names[0]
  subnet                = module.vpc.subnets_by_region[var.region].self_link
  tags = [
    "bastion",
  ]
  labels = var.labels
  bastion_targets = {
    cidrs = [
      "172.16.0.0/16",
    ]
    service_accounts = null
    tags             = null
    priority         = 900
  }
  depends_on = [
    module.vpc,
    module.restricted_apis_dns,
  ]
}

resource "google_compute_firewall" "bastion" {
  project     = var.project_id
  name        = format("%s-allow-proxy-ingress", var.name)
  network     = module.vpc.self_link
  description = format("Allow tester access to proxy (%s)", var.name)
  direction   = "INGRESS"
  source_ranges = [
    format("%s/32", trimspace(data.http.my_address.response_body)),
  ]
  target_service_accounts = [
    module.bastion.service_account,
  ]
  allow {
    protocol = "TCP"
    ports = [
      8888,
    ]
  }
  depends_on = [
    module.bastion,
  ]
}

resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  repository_id = var.name
  format        = "DOCKER"
  location      = var.region
  description   = "Private repo for NGINX Ingress Controller demo"
  labels        = var.labels
}
