# Cluster

The Terraform in this folder will create a private GKE Autopilot cluster that
uses a limited access service account. A kubeconfig file will be generated in
`../generated/` that can be used to administer the cluster via a IAP proxy.

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

# The qualified artifact registry repo
repo = "us-west1.docker.pkg.dev/my-gcp-project/my-repo"

# The subnet definition to use: must contain a subnet self-link, the names of
# the secondary ranges for pods and services, and a non-conflicting CIDR to use
# for master nodes.
subnet = {
    self_link = "https://www.googleapis.com/compute/v1/projects/my-gcp-project/regions/us-west1/subnetworks/my-subnet"
}

# A list of CIDRs that can access the master nodes
master_authorized_networks = [
    {
        cidr_block = "172.16.0.0/16"
        display_name = "via bastion"
    }
]

# Optional labels to add to resources
labels = {
    "owner" = "tester-name"
}

# Optional: override the default path where the generated kubeconfig will be
# written
kubeconfig_path = "~/tmp/kubeconfig"
```

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.63 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | memes/private-gke-cluster/google//modules/autopilot | 1.0.2 |
| <a name="module_kubeconfig"></a> [kubeconfig](#module\_kubeconfig) | memes/private-gke-cluster/google//modules/kubeconfig | 1.0.2 |
| <a name="module_sa"></a> [sa](#module\_sa) | memes/private-gke-cluster/google//modules/sa | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | A set of CIDRs that are permitted to reach the kubernetes API endpoints. | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name to use when naming resources managed by this module. Must be RFC1035<br/>compliant and between 1 and 63 characters in length, inclusive. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the Autopilot GKE cluster will be created. | `string` | n/a | yes |
| <a name="input_repo"></a> [repo](#input\_repo) | The generated service account will be given read-only access role to the repo. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Provides the subnet self\_link to which the cluster will be attached, the<br/>*names* of the secondary ranges to use for pods and services, and the CIDR to<br/>use for masters. | <pre>object({<br/>    self_link           = string<br/>    pods_range_name     = string<br/>    services_range_name = string<br/>    master_cidr         = string<br/>  })</pre> | n/a | yes |
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | The path that will be used for a generated kubeconfig; if left blank (default)<br/>the kubeconfig will be written to '../generated/kubeconfig'. | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of key:value string pairs that will be added to the Autopilot<br/>resources. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
