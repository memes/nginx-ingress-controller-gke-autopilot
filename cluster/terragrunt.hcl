include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "./"
}

dependencies {
  paths = [
    "${get_path_to_repo_root()}/foundations",
  ]
}

dependency "foundations" {
  config_path = "${get_path_to_repo_root()}/foundations"
}

inputs = {
  project_id = include.root.inputs.project_id
  name = include.root.inputs.name
  labels = include.root.inputs.labels
  repo = dependency.foundations.outputs.repo
  subnet = {
    self_link = dependency.foundations.outputs.subnet.self_link
    pods_range_name = dependency.foundations.outputs.subnet.pods_range_name
    services_range_name = dependency.foundations.outputs.subnet.services_range_name
    master_cidr = "192.168.0.0/28"
  }
  master_authorized_networks = [
    {
      cidr_block = format("%s/32", dependency.foundations.outputs.bastion_ip_address)
      display_name = "Bastion access to masters"
    },
  ]
  kubeconfig_path = abspath("${get_terragrunt_dir()}/../generated/kubeconfig")
}
