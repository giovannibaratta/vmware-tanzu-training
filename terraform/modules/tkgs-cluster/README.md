# tkgs-cluster

This module can be used to create TKGs cluster in a vSphere environment. Due to some restriction of the supervisor clusters (RBAC), the kubernetes_manifest resource can not be used and we need to rely on the Kubernetes CLI and manually manage the lifecycle of the resources.

## Prerequisites

* kubectl CLI

## Destroy a cluster

If you wan to destroy a cluster, you can not remove immediately the resource from the code base. You have to use the variable `desired_state` to trigger the destruction and than safely remove the code.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | n/a | `string` | n/a | yes |
| cluster\_namespace | n/a | `string` | n/a | yes |
| storage\_class | n/a | `string` | n/a | yes |
| tkr | n/a | `string` | n/a | yes |
| vm\_class | n/a | `string` | n/a | yes |
| additional\_ca | CA bundle to inject in the nodes in PEM format | `string` | `null` | no |
| control\_plane\_replicas | n/a | `number` | `1` | no |
| desired\_state | n/a | `string` | `"PRESENT"` | no |
| supervisor\_context\_name | n/a | `string` | `null` | no |
| worker\_node\_replicas | n/a | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | n/a |
<!-- END_TF_DOCS -->