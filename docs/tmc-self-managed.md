## Installation (TKGs)

[Install TMC SM](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/install-tmc-sm.html)

1. Install cert manager
    ```bash
    kubectl create ns tkg-packages
    tanzu package repository add tanzu-standard --url projects.registry.vmware.com/tkg/packages/standard/repo:v2.2.0 --namespace tkg-packages
    tanzu package install cert-manager -p cert-manager.tanzu.vmware.com -n tkg-packages -v 1.10.2+vmware.1-tkg.1
    ```
1. Create cluster issuer
1. Retrieve cluster issuer CA cert
    ```bash
    kubectl get secret -n cert-manager self-signed-root-ca-tls -o jsonpath='{.data.tls\.crt}' | base64 -d
    ```
1. Relocate images to private registry using TMC installer deployed in the **jumpbox**
1. Relocate Tanzu packages to private registry
1. Configure Kapp controller to trust CA of the private registry. See [this](https://carvel.dev/kapp-controller/docs/v0.45.0/controller-config/) for more details.
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      # Name must be `kapp-controller-config` for kapp controller to pick it up
      name: kapp-controller-config
      # Namespace must match the namespace kapp-controller is deployed to
      namespace: tkg-system
    stringData:
      # A cert chain of trusted ca certs.
      caCerts: |
        -----BEGIN CERTIFICATE-----
        -----END CERTIFICATE-----
    ```
1. Reload Kapp controller
    ```bash
    kubectl delete pod -n tkg-system -l app=kapp-controller
    ```
1. Add TMC SM repository
    ```bash
    kubectl create ns tmc-local
    tanzu package repository add tanzu-mission-control-packages --url "harbor.h2o-2-22574.h2o.vmware.com/tmc-sm/package-repository:1.1.0" --namespace tmc-local
    ```
1. Label NS
    ```bash
    kubectl label ns tmc-local pod-security.kubernetes.io/enforce=privileged
    ```
1. Prepare values file
  a. Add all the CAs for self-hosted services like Harbor, IDP, Git and TMC in `trustedCAs`
  a. Allocate a static IP address and setup DNS entries
1. Install TMC SM package
    ```bash
    tanzu package install tanzu-mission-control -p "tmc.tanzu.vmware.com" --version 1.1.0 --values-file tmc-sm-v1.1.0-values.yaml --namespace tmc-local
    ```
1. Upload Tanzu standard packages and cluster inspection dependencies. See [this](https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.1/tanzumc-sm-install/tanzu-conf-images.html) for more details
1. Register the supervisor
  a. Install agent config to add trust in the supervisor
  a. Start registration procedure from TMC and copy the link
  a. Paste the link in the vCenter
  a. After a few minutes this is the expected result in the supervisor cluster
    ```bash
    # TMC SM 1.1, TKGs 2.2, vSphere 8u2
    ➜ kubectl get pods -n svc-tmc-c8                         
    NAME                                          READY   STATUS      RESTARTS   AGE
    agent-updater-55b787fb7f-nbfpt                1/1     Running     0          3m48s
    agentupdater-workload-28455003-cx4g2          0/1     Completed   0          13s
    cluster-health-extension-7bb8486d49-lpdxb     1/1     Running     0          2m37s
    domain-local-ds-6s87p                         1/1     Running     0          5m10s
    domain-local-ds-7vnt4                         1/1     Running     0          5m10s
    domain-local-ds-x4fd4                         1/1     Running     0          5m10s
    extension-manager-74999899d4-clsd4            1/1     Running     0          3m49s
    extension-updater-84c5f7b6bf-2psk6            1/1     Running     0          3m52s
    intent-agent-59dc656f6d-86lwh                 1/1     Running     0          2m29s
    sync-agent-686cf5cdd7-gdnsc                   1/1     Running     0          2m32s
    tmc-agent-installer-28455003-8gl47            0/1     Completed   0          13s
    tmc-auto-attach-7ccbdd844f-bkgmg              1/1     Running     0          2m30s
    vsphere-resource-retriever-7644d68c8d-llsw8   1/1     Running     0          2m26s
    ```

## Add trust for private registry in workload cluster

> Tested on: TMC SM 1.1

> Certificate specified in the values file of TMC are automatically added to newly created cluster

1. Create a secret like the one below in the supervisor in the same namespace in which the workload cluster will be deployed
    ```yaml
    apiVersion: v1
    data:
      my-registry: <double base64 encoded cert>
      my-root-ca: <double base64 encoded cert>
    kind: Secret
    metadata:
      name: <cluster-name>-user-trusted-ca-secret
      namespace: <vsphere-namespace>
    type: Opaque
    ```
1. While creating the cluster in TMC, in the last section "Additional cluster configuration", click "Add trusted CA" and add the name of the fields in the data block of the previously created secret (e.g. my-root-ca)

[Integrate a TKGS Cluster with a Private Container Registry](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-EC2C9619-2898-4574-8EF4-EA66CFCD52B9.html?hWord=N4IghgNiBc4CZwJYBdEHsB2kAqAnArgM7ICmcAwgIKEgC+QA#v1beta1-api-example-3)

## Attach a cluster

1. Start the procedure from TMC
1. Apply the manifest with the link provided by TMC

## Additional notes

- If you are deploying an Harbor registry for the first time, you might need to upload some public available packages required for the installation to the private registry. See [this](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-35EB7EB7-7B4F-4C01-A4C5-551D8C0D4409.html) link for more details.

## FAQ

**<i> How to let the kapp-controller trust a self-signed certificate of the Harbor registry ?</i>**

The certificate can be injected using a secret or a config map, see [here](https://carvel.dev/kapp-controller/docs/latest/controller-config/) for more details .

**<i> The pods are failing because the secrets containing TLS certificate can not be found</i>**

Verify if the `certificaterequests` CRD have been created in the namespace used to install TMC. Verify that the issuer specified in the values file is of type ClusterIssuer.
