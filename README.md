# NGINX Ingress Controller with GKE Autopilot

![GitHub release](https://img.shields.io/github/v/release/memes/nginx-ingress-controller-gke-autopilot?sort=semver)
![Maintenance](https://img.shields.io/maintenance/yes/2023)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

## Usage

### Create the foundations and launch a private GKE Autopilot cluster

We recommend [Terragrunt] to make sure that resources are created in the right
order. Straight Terraform can be used but you will be responsible for connecting
the output of dependent modules.

1. Copy `terragrunt.hcl.example` to `terragrunt.hcl`
2. Edit `terragrunt.hcl` to use your GCP project, preferred region, etc.
3. Execute `terragrunt` in the repo root

   ```shell
   terragrunt run-all apply
   ```

4. Launch an IAP tunnel to bastion

   This will provide a local HTTP proxy that can reach the GKE Autopilot masters.

   ```shell
   eval $(terragrunt run-all --terragrunt-include-dir foundations output -raw tunnel_command)
   ```

   ```text
   ...
   Testing if tunnel connection works.
   Listening on port [8888].
   ```

5. Verify the GKE Autopilot cluster can be administered with kubectl

   ```shell
   kubectl --kubeconfig ./generated/kubeconfig get nodes
   ```

   ```text
   NAME                                         STATUS   ROLES    AGE   VERSION
   gk3-emes-nic-ap-default-pool-0040fa67-vl1p   Ready    <none>   60m   v1.24.10-gke.2300
   gk3-emes-nic-ap-default-pool-104cbf31-f8vx   Ready    <none>   60m   v1.24.10-gke.2300
   ```

### Populate the private repo

#### Copy the OSS NGINX Ingress Controller to the private repo

```shell
export PRIVATE_REPO="$(terragrunt run-all --terragrunt-working-dir foundations output -raw repo)"
gcrane cp --platform linux/amd64 nginx/nginx-ingress:3.1.1 ${PRIVATE_REPO}/nginx-ingress:3.1.1
```

```text
2023/05/05 14:38:16 Copying from nginx/nginx-ingress:3.1.1 to us-west1-docker.pkg.dev/my-project/my-repo/nginx-ingress:3.1.1
2023/05/05 14:38:20 pushed blob: sha256:3b9dbaacc5a6e08bcc650c8b9e8f38090972ecefdf8064c0413f4c48e9a97a72
...
2023/05/05 14:40:31 us-west1-docker.pkg.dev/my-project/my-repo/nginx-ingress:3.1.1: digest: sha256:e9e7222c4592c31ea56457e883f50bbdf2116fee11ecfd6f42353b311f6c8a16 size: 3893
```

#### Copy the NGINX+ Ingress Controller to the private repo

If you have purchased a license for NGINX Ingress Controller with NGINX+, copy
the files to your private repo. In this example I'm using my NGINX+ JWT key to
grant access to NGINX's customer registry.

> NOTE: See [Pulling the Ingress Controller Image](https://docs.nginx.com/nginx-ingress-controller/installation/pulling-ingress-controller-image/) for alternative methods.

1. Login to the NGINX private registry

   ```shell
   echo none | gcrane auth login --username $(cat ~/path/to/nginx/jwt) --password-stdin private-registry.nginx.com
   ```

   ```text
   2023/05/05 15:20:42 logged in via /Users/memes/.docker/config.json
   ```

2. Copy the NGINX+ Ingress Controller

   ```shell
   gcrane cp --platform linux/amd64 private-registry.nginx.com/nginx-ic/nginx-plus-ingress:3.1.1 ${PRIVATE_REPO}/nginx-plus-ingress:3.1.1
   ```

   ```text
   2023/05/05 15:22:36 Copying from private-registry.nginx.com/nginx-ic/nginx-plus-ingress:3.1.1 to us-west1-docker.pkg.dev/my-project/my-repo/nginx-plus-ingress:3.1.1
   2023/05/05 15:22:39 existing blob: sha256:b5d25b35c1dbfa256bea3dd164b2048d6c7f8074a555213c493c36f07bf4c559
   ...
   2023/05/05 15:23:06 pushed blob: sha256:1776e6398676d9009a4dd9a42db15c158688ca8c8c7a711393b1e140cc69d92f
   2023/05/05 15:23:06 us-west1-docker.pkg.dev/my-project/my-repo/nginx-plus-ingress@sha256:265a9a23afe415f755f1a5d6bf76e52413fed96cb257548358662c68747a1bcc: digest: sha256:265a9a23afe415f755f1a5d6bf76e52413fed96cb257548358662c68747a1bcc size: 562
   2023/05/05 15:23:06 us-west1-docker.pkg.dev/my-project/my-repo/nginx-plus-ingress:3.1.1: digest: sha256:5ae45a792ba43406c95a554d76d010ee9a85ef119ee268c02352564eb36695c6 size: 1609
   ```

### Deploy NGINX OSS Ingress Controller

> NOTE: Make sure the IAP tunnel to bastion is running before executing these
> commands!

```shell
kustomize build generated/oss | kubectl --kubeconfig generated/kubeconfig apply -f -
```

<!-- spell-checker: disable -->
```text
namespace/nginx-ingress configured
customresourcedefinition.apiextensions.k8s.io/globalconfigurations.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/policies.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/transportservers.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/virtualserverroutes.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/virtualservers.k8s.nginx.org configured
serviceaccount/nginx-ingress configured
clusterrole.rbac.authorization.k8s.io/nginx-ingress configured
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress configured
configmap/nginx-config configured
secret/default-server-secret configured
service/nginx-ingress configured
Warning: Autopilot increased resource requests for Deployment nginx-ingress/nginx-ingress to meet requirements. See http://g.co/gke/autopilot-resources
deployment.apps/nginx-ingress configured
ingressclass.networking.k8s.io/nginx configured
```
<!-- spell-checker: enable -->

### Deploy NGINX+ Ingress Controller

> NOTE: Make sure the IAP tunnel to bastion is running before executing these
> commands!

```shell
kustomize build generated/plus | kubectl --kubeconfig generated/kubeconfig apply -f -
```

<!-- spell-checker: disable -->
```text
namespace/nginx-ingress configured
customresourcedefinition.apiextensions.k8s.io/globalconfigurations.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/policies.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/transportservers.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/virtualserverroutes.k8s.nginx.org configured
customresourcedefinition.apiextensions.k8s.io/virtualservers.k8s.nginx.org configured
serviceaccount/nginx-ingress configured
clusterrole.rbac.authorization.k8s.io/nginx-ingress configured
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress configured
configmap/nginx-config configured
secret/default-server-secret configured
service/nginx-ingress configured
Warning: Autopilot increased resource requests for Deployment nginx-ingress/nginx-ingress to meet requirements. See http://g.co/gke/autopilot-resources
deployment.apps/nginx-ingress configured
ingressclass.networking.k8s.io/nginx configured
```
<!-- spell-checker: enable -->

## Cleanup

### Delete the NGINX Ingress Controller from cluster

```shell
kubectl --kubeconfig generated/kubeconfig delete namespace nginx-ingress
```

```text
namespace "nginx-ingress" deleted
```

### Destroy the infrastructure

```shell
terragrunt run-all destroy
```

[terragrunt]: https://terragrunt.gruntwork.io
