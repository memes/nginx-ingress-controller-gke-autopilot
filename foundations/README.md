# Foundations

The Terraform in this folder will create a private VPC with bastion host, and a
private artifact repository to store the NGINX Ingress Controller images.

## Configuration for Terragrunt

All configuration is in the top-level `terragrunt.hcl`.

## Configuration for standalone Terraform

Create a local `terraform.tfvars` file that configures the testing project
constraints.

```hcl
# The GCP project identifier to use
project_id  = "my-gcp-project"

# The name to apply to resources
name = "my-cluster"

# The single Compute Engine region where the resources will be created
region = "us-west1"

# Optional labels to add to resources
labels = {
    "owner" = "tester-name"
}
```

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.63 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | memes/private-bastion/google | 2.3.5 |
| <a name="module_restricted_apis_dns"></a> [restricted\_apis\_dns](#module\_restricted\_apis\_dns) | memes/restricted-apis-dns/google | 1.2.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | memes/multi-region-private-network/google | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_compute_firewall.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name to use when naming resources managed by this module. Must be RFC1035<br>compliant and between 1 and 63 characters in length, inclusive. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the foundational resources will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Compute Engine regions in which to create the foundation resources. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of key:value string pairs that will be added to the GCP resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_ip_address"></a> [bastion\_ip\_address](#output\_bastion\_ip\_address) | n/a |
| <a name="output_repo"></a> [repo](#output\_repo) | n/a |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | n/a |
| <a name="output_tunnel_command"></a> [tunnel\_command](#output\_tunnel\_command) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
