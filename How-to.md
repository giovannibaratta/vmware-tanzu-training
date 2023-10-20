## Retrieve the supervisor virtual machines password ?

Option A:
1. Connect to the vCenter server
1. Run `/usr/lib/vmware-wcp/decryptK8Pwd.py  | grep PWD | cut -d':' -f2 | cut -d' ' -f2`

## Retrieve all logs related to an operation in vCenter

1. Connect to the vCenter server
1. Identify the operation id in logs (e.g `[Originator@6876 sub=Vmomi opID=wcp-652e3122-16d6fe2b-fe99-416c-b534-7b2a0dbe9e1a-20]`)
1. Use the opId to filter the logs `grep wcp-652e3122-16d6fe2b-fe99-416c-b534-7b2a0dbe9e1a-20 *.log`

## Verify the status of a cluster

* Verify the status with `tanzu cluster list`
* Verify the deployed virtual machine in the supervisor cluster with `kubectl get machines`
* Verify the status of the machines using `kubectl describe machine <machine-name>``

## Let the cluster trust a self-signed CA (tanzukubernetescluster CRD)

* Add to the tanzukubernetescluster resource spec.settings.network.trust.additionalTrustedCAs
    ```
    - data: <base64 encoded certificate>
      name: <arbitrary name>
    ```

* Wait for Kubernetes to do the re-provisioning of the nodes (including the control plane)