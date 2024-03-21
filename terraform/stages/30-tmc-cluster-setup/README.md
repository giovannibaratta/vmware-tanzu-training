# TMC cluster setup

Tested with a TKGs cluster (TKG 2.2, Kubernetes 1.26.5).

## Prerequisites

* Tanzu Mission control images must already be uploaded in the private registry
* Identity service provider (Keycloak, Okta, ...)

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ca\_certificate | Certificate used to configure the cluster issuer | `string` | n/a | yes |
| ca\_private\_key | Private key used to configure the cluster issuer | `string` | n/a | yes |
| private\_registry\_ca | PEM certificate of the private registry that contains the TMC images | `string` | n/a | yes |
| tmc\_kubeconfig | Path to a kubeconfig for the tmc cluster | `string` | n/a | yes |
| tmc\_repo\_ref | Reference to the private registry that contains the images. Example: harbor.h2o-2-22574.h2o.vmware.com/tmc-sm/package-repository:1.1.0 | `string` | n/a | yes |
| tmc\_values | TMC values | `string` | n/a | yes |
| add\_trust\_to\_kapp\_controller | Configure the Kapp controller to trust the private registry | `bool` | `true` | no |
<!-- END_TF_DOCS -->