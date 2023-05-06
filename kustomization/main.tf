terraform {
  required_version = ">= 1.2"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
  }
}

resource "local_file" "oss" {
  filename = format("%s/oss/kustomization.yaml", coalesce(var.kustomization_path, format("%s/../generated", path.module)))
  content = templatefile(format("%s/templates/kustomization.oss.yaml", path.module), {
    repo        = var.repo
    annotations = var.annotations
  })
}


resource "local_file" "plus" {
  filename = format("%s/plus/kustomization.yaml", coalesce(var.kustomization_path, format("%s/../generated", path.module)))
  content = templatefile(format("%s/templates/kustomization.plus.yaml", path.module), {
    repo        = var.repo
    annotations = var.annotations
  })
}
