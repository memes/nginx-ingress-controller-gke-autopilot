terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.63"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
  }
}

module "sa" {
  source       = "memes/private-gke-cluster/google//modules/sa"
  version      = "1.0.2"
  project_id   = var.project_id
  name         = var.name
  display_name = "GKE Autopilot"
  description  = "NGINX Ingress Controller on GKE Autopilot nodes"
  repositories = [
    var.repo,
  ]
}

module "gke" {
  source                     = "memes/private-gke-cluster/google//modules/autopilot"
  version                    = "1.0.2"
  project_id                 = var.project_id
  name                       = var.name
  description                = "Demonstration of NGINX Ingress Controller on private GKE Autopilot"
  subnet                     = var.subnet
  master_authorized_networks = var.master_authorized_networks
  service_account            = module.sa.email
  labels                     = var.labels
}

module "kubeconfig" {
  source               = "memes/private-gke-cluster/google//modules/kubeconfig"
  version              = "1.0.2"
  cluster_id           = module.gke.id
  cluster_name         = var.name
  context_name         = var.name
  use_private_endpoint = true
  proxy_url            = "http://localhost:8888"
}

resource "local_file" "kubeconfig" {
  filename = coalesce(var.kubeconfig_path, format("%s/../generated/kubeconfig", path.module))
  content  = module.kubeconfig.kubeconfig
  depends_on = [
    module.kubeconfig,
  ]
}
