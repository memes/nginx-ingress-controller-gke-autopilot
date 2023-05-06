include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "./"
}

inputs = {
  project_id = include.root.inputs.project_id
  name       = include.root.inputs.name
  region     = include.root.inputs.region
  labels     = include.root.inputs.labels
}
