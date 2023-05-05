output "subnet" {
  value = {
    self_link           = module.vpc.subnets_by_region[var.region].self_link
    pods_range_name     = "pods"
    services_range_name = "services"
  }
}

output "bastion_ip_address" {
  value = module.bastion.ip_address
}

output "tunnel_command" {
  value = module.bastion.tunnel_command
}

output "repo" {
  value = format("%s-docker.pkg.dev/%s/%s", google_artifact_registry_repository.repo.location, google_artifact_registry_repository.repo.project, google_artifact_registry_repository.repo.name)
}
