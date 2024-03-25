# TAP

## Deploy TAP

The following steps will guide you on how to deploy a multi cluster installation of TAP that can be managed using a GitOps approach. The stack will deployed with the help of TMC self-managed. The whole stack is deployed using Terraform and a few helper scripts. The user is still responsible for a few actions that are not easy to automate and orchestrate with the current tools.

> The process has been tested against commit 2c44f670847c26ece298d787a8509ff2d9fa1224

### Prerequisites

- vSphere with workload management enabled
- kubectl CLI
- tmc CLI
- access to DNS provider
- Terraform CLI

> The procedure has been tested in vCenter 8.0.2.00200 with NSX and supervisor v1.26.8+vmware.1-fips.1-vsc0.1.7-23316887.

### Terraform state

The terraform modules do not have a configured Terraform state. You can use a local state or configure a remote state. If a modules needs an input parameter produced by another one, it will be read from a local generate file.

### 1. Setup certificate authority

In this step we will generate a self-signed CA that will be used to generate certificates for the other components.

The stage that will be used in this step is [00-bootstrap](../terraform/stages/00-bootstrap/).

1. `cd` into [Terraform root dir](../terraform/)
1. (Optional) create a file in the stage directory to configure a Terraform backend
1. Create a file named `terraform.tfvars` in the stage directory and set a value for the domain.
   ```yaml
   domain = "h2o-2-23532.h2o.vmware.com"
   ```
1. initialize Terraform

   ```sh
   ./tf-helper init 00-bootstrap
   ```

1. apply Terraform
   ```sh
   ./tf-helper apply 00-bootstrap
   ```
1. inspect the generated output in the folder `outputs/00-bootstrap` in the Terraform root dir

### 2. Deploy private registry and IDP VMs

In this step we will deploy the base infrastructure to host a private registry and a IDP (Keycloak).

The stage that will be used in this step is [10-deploy-services-infra](../terraform/stages/10-deploy-services-infra/).

1. `cd` into [Terraform root dir](../terraform/)
1. Export the vSphere password that will be used by the Terraform provider
   ```sh
   export TF_VAR_vsphere_password="REPLACE ME"
   ```
1. (Optional) create a file in the stage directory to configure a Terraform backend
1. Create a file named `terraform.tfvars` in the stage directory and set a value for the required variables.<br><br>You have to specify the variables necessary to identify in which custer, datastore, ... the resources will be deployed and a SSH key that will be pushed into the VMs. You also have to specify which services must be deployed, in this case we need to a private registry and the IDP service.<br><br>Last but not least, the stage will automatically upload an OVA image to be used as a template. This might require a lot of time, you can therefore specify a reference to an existing template that you manually uploaded to the vCenter (Ansible playbooks have been tested using an Ubuntu 22.04 image).<br><br>A list of all the supported variables is available [here](../terraform/stages/10-deploy-services-infra/README.md).

   ```yaml
   terraform.tfvars
   vm_authorized_key = "ssh-ed25519 ..."

   services = {
   registry = true
   idp = true
   }
   # Optional
   # vm_template = {
   #  library_name = ""
   #  template_name = ""
   # }
   ```

1. initialize Terraform

   ```sh
   ./tf-helper init 10-deploy-services-infra
   ```

1. apply Terraform and note down the returned ips
   ```sh
   ./tf-helper apply 10-deploy-services-infra
   ```
1. inspect the generated output in the folder `outputs/10-deploy-services-infra` in the Terraform root dir
1. Register the IPs in the DNS as `idp.<DOMAIN>` and `registry.<DOMAIN>` where `<DOMAIN>` is the domain specified in the Terraform variables.

### 3. Deploy TKG cluster to install TMC SM

In this step we will deploy a TKG that will host TMC SM. Due to how Terraform works, it is challenging to deploy and configure the cluster in a single module, therefore we will split this in two steps. The stage relies on `kubectl` to create the cluster because the Kubernetes provider for Terraform is not compatible with the supervisor control plan due to strict RBAC policies.

The stage that will be used in this step is [10-deploy-tkgs-clusters](../terraform/stages/10-deploy-tkgs-clusters/).

1. Before creating the cluster we need to prepare the vSphere environment. These resources cannot be created using Terraform, hence we will create them manually.

   1. Create a vSphere namespace called `mgmt`
   1. Assign to the vSphere namespace a storage policy
   1. Assign to the vSphere namespace a VM class

1. Login to supervisor control plane
   ```sh
    kubectl vsphere login --vsphere-username <USERNAME> --server=<SERVER>
   ```
1. `cd` into [Terraform root dir](../terraform/)
1. (Optional) create a file in the stage directory to configure a Terraform backend
1. Create a file named `terraform.tfvars` in the stage directory and set a value for the required variables.<br><br>You have to specify the supervisor context, the namespace, policy and class assigned before and few additional parameters.<br><br>A list of all the supported variables is available [here](../terraform/stages/10-deploy-tkgs-clusters/README.md).

1. initialize Terraform

   ```sh
   ./tf-helper init 10-deploy-tkgs-clusters
   ```

1. apply Terraform and note down the returned ips

   ```sh
   ./tf-helper apply 10-deploy-tkgs-clusters
   ```

1. inspect the generated output in the folder `outputs/10-deploy-tkgs-clusters` in the Terraform root dir

### 4. Configure Harbor and IDP

In this step we will create the Harbor projects that are necessary to relocate the packages and 2 OIDC providers in Keycloak.

The stage that will be used in this step is [20-configure-services](../terraform/stages/20-configure-services/).

1. `cd` into [Terraform root dir](../terraform/)
1. (Optional) create a file in the stage directory to configure a Terraform backend
1. Create a file named `terraform.tfvars` in the stage directory and set a value for the required variables.<br><br>You have to specify the supervisor context, the namespace, policy and class assigned before and few additional parameters.<br><br>A list of all the supported variables is available [here](../terraform/stages/20-configure-services/).

1. initialize Terraform

   ```sh
   ./tf-helper init 20-configure-services
   ```

1. apply Terraform and note down the returned ips

   ```sh
   ./tf-helper apply 20-configure-services
   ```

1. inspect the generated output in the folder `outputs/20-configure-services` in the Terraform root dir

### 5. Relocate the packages

In this step we will upload TAP and TMC packages into our private registry. There is no Terraform stage for doing this, we will manually upload the packages. The following actions can be performed from the jumpbox deployed in stage #2.

1. Retrieve the IP of the jumpbox from the Terraform output of the previous stage
1. Connect via SSH to the jumpbox using the user `ubuntu` and the SSH key specified in the variables of step #2
1. Copy the CA certificate created in the step #1 into the jumpbox. The file must have `.crt`extension. Then run the following commands
   ```sh
   sudo cp ca.crt /usr/local/share/ca-certificates
   sudo update-ca-certificates
   ```
1. Download and pack the latest version of the (cluster essentials)[https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/#/releases/1462363]. Do not install the them, we just need the `imgpkg` executable
   ```sh
   sudo install imgpkg /usr/local/bin
   ```
1. Follow the steps describe in [Relocate images to a registry](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.8/tap/install-online-profile.html#relocate-images-to-a-registry-0)
   ```sh
   export IMGPKG_REGISTRY_HOSTNAME_1=registry.<DOMAIN>
   export IMGPKG_REGISTRY_USERNAME_1=<CAN_BE_RETRIEVED_FROM_OUTPUT_OF_STEP_#2>
   export IMGPKG_REGISTRY_PASSWORD_1=<CAN_BE_RETRIEVED_FROM_OUTPUT_OF_STEP_#2>
   export TAP_VERSION="1.8.1"
   export INSTALL_REPO="tap"
   ```
1. Follow the steps describe in [Download and stage the installation images](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/install-tmc-sm.html#download-and-stage-the-installation-images-0).
   ```sh
   tanzumc/tmc-sm push-images harbor --project "registry.<DOMAIN>/tmc-sm" --username "<CAN_BE_RETRIEVED_FROM_OUTPUT_OF_STEP_#2>" --password "<CAN_BE_RETRIEVED_FROM_OUTPUT_OF_STEP_#2>"
   ```
1. Follow the steps described in [Copy Tanzu Standard package repository images](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/tanzu-conf-images.html#copy-tanzu-standard-package-repository-images-0)
   ```sh
   imgpkg copy --registry-ca-cert-path=ca.crt \
   -b projects.registry.vmware.com/tkg/packages/standard/repo:v2023.7.13_update.2 \
   --to-repo "registry.<DOMAIN>/tmc-sm/498533941640.dkr.ecr.us-west-2.amazonaws.com/packages/standard/repo"
   ```

### 6. Deploy TMC SM

In this step we will deploy TMC in the cluster created in the step #3.

The stage that will be used in this step is [30-tmc-cluster-setup](../terraform/stages/30-tmc-cluster-setup/).

1. `cd` into [Terraform root dir](../terraform/)
1. (Optional) create a file in the stage directory to configure a Terraform backend

1. initialize Terraform

   ```sh
   ./tf-helper init 30-tmc-cluster-setup
   ```

1. apply Terraform

   ```sh
   ./tf-helper apply 30-tmc-cluster-setup
   ```

1. Connect to the cluster and retrieve the IP of the load balancer and register the IP in the DNS for the hostname `tmc.<domain>` and `*.tmc.<domain>`

   ```sh
   kubectl get svc -n tmc-local contour-envoy
   ```

1. Once the packages have been reconciled, connect to TCM (<i>https://tmc.<DOMAIN>/</i>) using the credentials contained in the output of step #4
1. Start the procedure to register the supervisor and manually apply the following manifests into the supervisor
   ```yaml
   apiVersion: "installers.tmc.cloud.vmware.com/v1alpha1"
   kind: "AgentConfig"
   metadata:
     name: "tmc-agent-config"
     namespace: svc-tmc-c8
   spec:
     allowedHostNames:
       - "tmc.<DOMAIN>"
     caCerts: |-
       # Add CA
   ```
   ```yaml
   apiVersion: installers.tmc.cloud.vmware.com/v1alpha1
   kind: AgentInstall
   metadata:
     name: tmc-agent-installer-config
     namespace: svc-tmc-c8
   spec:
     operation: INSTALL
     registrationLink: <LINK_GENERATED_BY_TMC>
   ```

> If during the apply you received the following error, reapply Terraform again.<br><br>`Error from server (InternalError): error when creating "./files/cert-manager-issuer.yaml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://cert-manager-webhook.cert-manager.svc:443/mutate?timeout=10s": x509: certificate signed by unknown authority`

### 7. Deploy TAP

The stage that will be used in this step is [50-tmc](../terraform/stages/50-tmc/).

1. Before deploying TAP we need to prepare the vSphere environment. These resources cannot be created using Terraform, hence we will create them manually.

   1. Create a vSphere namespace called `tap`
   1. Assign to the vSphere namespace a storage policy
   1. Assign to the vSphere namespace a VM class

1. Generate an AGE key to encrypt TAP values

   ```sh
   age-keygen -o key.txt
   ```

1. Create a Git repository and push the code contained in [this folder](../manifests/flux-tap/multi-cluster/). The configurations files must be customized:
   - TAP values files for [view](../manifests/flux-tap/multi-cluster/overlays/view/tap-values/tap-values.yaml.encrypted), [build](../manifests/flux-tap/multi-cluster/overlays/build/tap-values/tap-values.yaml.encrypted), [run](../manifests/flux-tap/multi-cluster/overlays/run/tap-values/tap-values.yaml.encrypted), [iterate](../manifests/flux-tap/multi-cluster/overlays/iterate/tap-values/tap-values.yaml.encrypted) profiles. These files must be encrypted with the AGE key generate before.
   ```sh
   export SOPS_AGE_RECIPIENTS="<AGE_PUBLIC_KEY>
   sops --encrypt --input-type yaml --mac-only-encrypted --encrypted-regex '^.*([pP]assword|[sS]ecret|serviceAccountToken).*$' tap-values.yaml > tap-values.yaml.encrypted
   ```
   - cluster issuer [certificate](../manifests/flux-tap/multi-cluster/base/configure-cert-manager/root-ca.crt) and [private key](../manifests/flux-tap/multi-cluster/base/configure-cert-manager/root-ca.key.encrypted)
1. `cd` into [Terraform root dir](../terraform/)
1. (Optional) create a file in the stage directory to configure a Terraform backend
1. Initialize the TMC CLI and login to the TMC endpoint (provisioner name is `tap`)
   ```sh
   tmc system context create --self-managed -e <endpoint>:443 -n <context-name> --basic-auth
   ```
1. Create a file named `terraform.tfvars` and add the required variables.
1. initialize Terraform

   ```sh
   ./tf-helper init 50-tmc
   ```

1. apply Terraform

   ```sh
   ./tf-helper apply 50-tmc
   ```

1. Register DNS entries with FQDN names reported by `HTTPProxies` generated during the installation and assign them to the envoy proxies IP.
1. The [view profile](../manifests/flux-tap/multi-cluster/overlays/view/tap-values/tap-values.yaml.encrypted) needs two service account tokens of the build and run clusters that will be created when installing TAP. These tokens and the certificate authority of the Kubernetes API must be updated at the end of the deployment.
   ```sh
   kubectl get secrets -n tap-gui tap-gui-viewer -o jsonpath='{.data.token}' | base64 -d
   ```

> If you get the following error while applying the Terraform stage, you need to login again to the TMC endpoint using the `tmc`CLI<br><br>` Error: Get "https://X.Y.Z.K:6443/api/v1/namespaces/tanzu-continuousdelivery-resources/secrets/sops-keys": getting credentials: exec: executable tmc failed with exit code 1`

### 8. Verify deployment

1. Log in in the TAP clusters

   ```sh
   kubectl vsphere login --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify --server=<SUPERVISOR> --tanzu-kubernetes-cluster-namespace=tap --tanzu-kubernetes-cluster-name=tap-<build|run|iterate|view>
   ```

1. Check if packages have been reconciled

   ```sh
   for context in view iterate run build; do kubectl get apps -n tap-install --context "tap-${context}"; done
   ```

1. Check if Kustomizations have been applied

   ```sh
   for context in view iterate run build; do kubectl get kustomizations -n tanzu-continuousdelivery-resources --context "tap-${context}"; done
   ```

## Additional reference

[Docs entry point](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.7/tap/overview.html)
