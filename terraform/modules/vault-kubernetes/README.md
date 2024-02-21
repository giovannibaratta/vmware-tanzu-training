# vault-kubernetes

The module is responsible for enabling and configuring an auth backend of type [Kubernetes](https://developer.hashicorp.com/vault/docs/auth/kubernetes).

The Kubernetes backend supports different modes to authenticate to the Kubernetes cluster to validate the caller JWT. The module configures the backend to use the caller JWT to perform the authentication. The Kubernetes cluster must have the proper [ClusterRoleBindings](https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt) to work.


The module creates a role foreach entry in the variable `roles`. The entry must specify to which namespaces/service accounts the role will be mapped and which policies will be attached to the tokens.
## Prerequisites

* a Kubernetes cluster

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kubernetes\_config | n/a | <pre>object({<br>    host = string<br>    ca = string<br>  })</pre> | n/a | yes |
| roles | n/a | <pre>map(object({<br>    name = string<br>    service_account_names = optional(set(string), ["*"])<br>    namespaces = set(string)<br>    policies_to_attach = optional(set(string), [])<br>  }))</pre> | `{}` | no |
<!-- END_TF_DOCS -->