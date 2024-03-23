# Vault Agent Injector

## Prerequisites
* a Vault cluster
* a Kubernetes cluster

## Instructions

1. Enable and configure a Kubernetes auth backend in the Vault cluster. A Terraform module is available [here](../terraform/modules/vault-kubernetes/) and an example on how to use it is also available [here](../terraform/stages/50-vault/). These steps can also be performed using the Vault CLI.
1. Deploy the Agent Injector using the official helm chart. An example of values file is available [here](../manifests/vault-injector-helm-values.yaml).
    ```sh
    helm install -f vault-injector-helm-values.yaml vault-injector hashicorp/vault --version 0.27.0  -n vault
    ```
1. Annotate the namespace using the labels specified in the selector used for the installation.
    ```sh
    kubectl label ns go-yada vault-injector=true
    ```
1. Deploy an application in the annotated namespace. The manifest of the application must contains the necessary annotations that are necessary to Vault to know which secrets must be injected and in which location. Remember also to grant the necessary permissions to the service account used by the application. See [here](../manifests/go-yada.yaml) for an example.