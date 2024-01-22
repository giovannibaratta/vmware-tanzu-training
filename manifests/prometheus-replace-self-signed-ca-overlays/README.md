# Replace self-signed CA

The folder contains a set of overlays to be applied during the installation of Prometheus package. The overlays remove the self-signed issuer and inject the provided issuer reference in the certificate request.

## Usage

Use the `ytt-overlay-file` flag and specify this directory as the value to apply the overlays contained in this folder.

```sh
tanzu package install prometheus -n tkg-packages  -p prometheus.tanzu.vmware.com -v 2.37.0+vmware.3-tkg.1 --values-file prometheus-values.yaml --ytt-overlay-file prometheus-replace-self-signed-ca-overlays
```
