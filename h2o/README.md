## Prerequisites
1. Define a namespace in vSphere. A Kubernetes namespace should be automatically created in the supervisor cluster.
1. Attach a storage policy, a content library and a VM class to the vSphere namespace.
1. (optional) Define a custom ClusterClass using `tanzukubernetescluster` class as a template

## Shared services cluster

1. Define a Cluster object that reference `tanzukubernetescluster` or the newly created custom class (see here [here](./cluster-shared-services.yaml))
1. Create the cluster using Tanzu CLI.
1. Apply the labels (to the supervisor resources)
    `kubectl label cluster.cluster.x-k8s.io/<clusterName> cluster-role.tkg.tanzu.vmware.com/tanzu-services="" --overwrite=true`

## Deploy Harbor in the shared services cluster (not as Supervisor Service)

These steps will deploy an Harbor registry into the shared services cluster

[Install cert-manager](https://docs.vmware.com/en/VMware-Tanzu-Packages/2023.9.19/tanzu-packages/packages-cert-mgr-super.html#cli)
[Install contour](https://docs.vmware.com/en/VMware-Tanzu-Packages/2023.9.19/tanzu-packages/packages-contour-super.html#cli)
[Install Harbor](https://docs.vmware.com/en/VMware-Tanzu-Packages/2023.9.19/tanzu-packages/packages-harbor-super.html)


1. Login to the supervisor cluster. Also switch context in Tanzu CLI
1. Verify that the <i>kapp-controller</i> is installed
    `kubectl get pods -A | grep kapp-controller`
1. Deploy cert-manager
    ```bash
    kubectl create ns cert-manager
    tanzu package install cert-manager -p cert-manager.tanzu.vmware.com -n cert-manager -v 1.12.2+vmware.1-tkg.1
    ```
1. Verify cert-manager installation
    `kubectl -n cert-manager get packageinstalls`
1. Deploy contour
    ```bash
    kubectl create ns tanzu-system-ingress
    tanzu package install contour -p contour.tanzu.vmware.com -v 1.25.2+vmware.1-tkg.1 --values-file contour-data-values.yaml -n tanzu-system-ingress
    ```
1. Verify contour installation
    `tanzu package installed list -n tanzu-system-ingress`
1. Install Harbor
    ```
    kubectl create ns tanzu-system-registry
    # Generate the values files necessary to install Harbor
    ./scripts/hydrates-harbor-data-values.sh gen-templates
    # Replace the secrets values in the generate file
    ./scripts/hydrates-harbor-data-values.sh hydrates
    tanzu package install harbor --package harbor.tanzu.vmware.com --version 2.8.4+vmware.1-tkg.1 --values-file ./harbor-data-values.yaml --namespace tanzu-system-registry
    ```
1. Verify Harbor installation
    `tanzu package installed get harbor --namespace tanzu-system-registry`
1. Set the dns entry to point the hostname set in `harbor-data-values.yaml` to the Contour load balancer. 