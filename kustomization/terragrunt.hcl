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
  repo               = dependency.foundations.outputs.repo
  kustomization_path = abspath("${get_terragrunt_dir()}/../generated")
}
