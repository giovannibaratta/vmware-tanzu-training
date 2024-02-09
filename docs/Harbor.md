# Harbor 

Habor Docs page: https://goharbor.io/docs/2.7.0/

## Installation (Tanzu package)

[Tanzu Harbor package docs](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.2/using-tkg/workload-packages-harbor.html)

The procedure below contains the steps to install Harbor using the Tanzu with a certificate emitted by cert-manager. If the TLS section is not configure, the package generates a self-signed CA that is used to generate the certificates.

1. Verify that yq is installed and version is 4.5 or later
   ```bash
   yq --version
   ```
   If it is not installed, download it from https://github.com/mikefarah/yq or https://snapcraft.io/install/yq/rhel
1. Add Tanzu repository
1. Download script to generate values (this step can be skipped and the values file can be generated manually)
   ```bash
   # Download image
   imgpkg pull -b 'projects.registry.vmware.com/tkg/packages/standard/harbor:v2.7.1_vmware.1-tkg.1' -o ./harbor-package-2.7.1+vmware.1-tkg.1
   ```
1. Create the namespace `tanzu-system-registry`
1. Create a secret containing the CA bundle that will be referenced in `caBundleSecretName`. The bundle will be injected into the trust store for core, jobservice, registry, trivy.
    ```bash
    kubectl create secret generic -n tanzu-system-registry ipzs-ca-bundle --from-file=/tmp/ca.crt
    ```
1. Apply the manifest to generate a certificate. Customize the properties according to your needs.
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
      name: harbor-tls-cert
      namespace: tanzu-system-registry
   spec:
      duration: 2160h # 90d
      renewBefore: 360h # 15d
      commonName: Harbor
      dnsNames:
         - <harbor fqdn>
      secretName: harbor-tls
      issuerRef:
         name: <issuer name>
   ```

1. Generate password (this step can be skipped if the values file has been generated manually)

   ```bash
   # Copy default template
   cp harbor-package-2.7.1+vmware.1-tkg.1/config/values.yaml harbor-data-values.yaml

   # Generate passwords
   bash ./harbor-package-2.7.1+vmware.1-tkg.1/config/scripts/generate-passwords.sh harbor-data-values.yaml
   ```

1. Set the following values in the values file
   a. `hostname`
   a. `tlsCertificateSecretName` with the secret name where the certificate data will be injected 
   a. storage classes if different than the default one
   a. Adjust registry size `persistence.persistentVolumeClaim.registry.size`

1. Remove all the values with default values
1. Remove comments with (overlay and other things will disappear)
   ```bash
   yq -i eval '... comments=""' harbor-data-values.yaml
   ```

1. Install package
   ```bash
    tanzu package install harbor \
    --package harbor.tanzu.vmware.com \
    --version 2.7.1+vmware.1-tkg.1 \
    --values-file harbor-data-values.yaml \
    --namespace tks-packages-220
    ```

## Configurations

The token used in the authorization header is the base64 encoding of `user:password`

### Configure LDAP

Use Harbor APIs to configure LDAP

```bash
curl -X 'PUT' \
  'https://<harbor fqdn>/api/v2.0/configurations' \
  -H 'accept: application/json' \
  -H 'authorization: Basic <token>' \
  -H 'Content-Type: application/json' \
  -d '{
"auth_mode": "ldap_auth",
"ldap_search_dn": "<ldap_dn>",
"ldap_search_password": "<ldap_password>",
"ldap_uid": "cn",
"ldap_url": "<ldap_fqdn>",
"ldap_verify_cert": true
}'
```

### Configure replication (push based)

* Add CA to the registry that will be configured to push the images
* Create a Robot account in the target registry
* Add endpoint targeting the target registry into the Source registry
* Configure replication policy into the source registry
  * Push based
  * based on tags (event based does not support labels)

## Notes

* Notary is used to verify that images are signed before pulling/pushing
* Notary deprecation from v2.9.0 https://github.com/goharbor/harbor/wiki/Harbor-Deprecates-Notary-v1-Support-in-v2.9.0 -> Use cosign or notation
* Chartmuseum deprecated in v2.6.0
* Trivy DB v1 deprecated : https://github.com/aquasecurity/trivy-db
* Internal TLS is enabled by default, verify with `kubectl describe deploy | grep INTERNAL_TLS_ENABLED`

## Links

Harbor Scanner Adapter for Trivy (Trivy v0.37.2): https://github.com/aquasecurity/harbor-scanner-trivy/tree/v0.30.7

Harbor APIs Auth: https://github.com/goharbor/harbor/wiki/Harbor-FAQs#api