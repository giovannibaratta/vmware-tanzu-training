apiVersion: run.tanzu.vmware.com/v1alpha3
kind: TanzuKubernetesCluster
metadata:
  name: ${cluster_name}
  namespace: ${cluster_namespace}
spec:
  topology:
    controlPlane:
      replicas: ${control_plane_replicas}
      vmClass: ${vm_class}
      storageClass: ${storage_class}
      tkr:
        reference:
          name: ${tkr}
      nodeDrainTimeout: 10m
    nodePools:
      - name: node-pool-default
        replicas: ${worker_node_replicas}
        vmClass: ${vm_class}
        storageClass: ${storage_class}
        tkr:
          reference:
            name: ${tkr}
        nodeDrainTimeout: 5m
  settings:
    storage:
      defaultClass: ${storage_class}
    network:
      cni:
        name: antrea
%{ if additional_ca != null ~}
      trust:
        additionalTrustedCAs:
          - name: ca-bundle
            data: ${additional_ca}
%{ endif ~}