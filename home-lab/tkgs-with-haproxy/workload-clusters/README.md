## Prerequisites
1. Define a namespace in vSphere. The namespace should be automatically be created in the supervisor cluster.
1. Attach a storage policy, a content library and a VM class to the vSphere namespace.
1. (optional) Define a custom ClusterClass using `tanzukubernetescluster` class as a template

## Shared services cluster

1. Define a Cluster object that reference `tanzukubernetescluster` or the newly created custom class (see here [here](./cluster-shared-services.yaml))
1. Create the cluster using Tanzu CLI.
1. Apply the labels (to the supervisor resources)
    `kubectl label cluster.cluster.x-k8s.io/<clusterName> cluster-role.tkg.tanzu.vmware.com/tanzu-services="" --overwrite=true`

