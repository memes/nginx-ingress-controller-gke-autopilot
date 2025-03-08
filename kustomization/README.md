# Kustomization

The Terraform in this folder will create additional kustomization files to pull
images from a private GAR repo.

## Configuration for Terragrunt

All configuration is in the top-level `terragrunt.hcl`.

## Configuration for standalone Terraform

Create a local `terraform.tfvars` file that configures the testing project
constraints.

```hcl
# The Google Artifact Registry repo to use as source of NGINX OSS/NGINX+ Ingress
# controller images
repo = "us-west1-docker.pkg.dev/my-project/my-repo"

# Optional: override the default path where the generated kustomize yaml files
# will be written
kustomization_path = "~/tmp/"
```

<!-- markdownlint-disable no-inline-html no-bare-urls -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.oss](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.plus](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repo"></a> [repo](#input\_repo) | The generated service account will be given read-only access role to the repo. | `string` | n/a | yes |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | An optional set of key:value string pairs that will be added generated resources<br/>that accept kubernetes style annotations. | `map(string)` | `{}` | no |
| <a name="input_kustomization_path"></a> [kustomization\_path](#input\_kustomization\_path) | The path that will be used for a generated kustomizations; if left blank (default)<br/>the kustomization files will be written to '../generated/'. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- markdownlint-enable no-inline-html no-bare-urls -->
