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

## Debug failed configuration of ESXI as Kubernetes node

Check  /var/log/vmware/wcp logs in the vCenter appliance
  * Search for logs using the opID, the op ID contains the host ID (e.g. opID=domain-c8-host-12)
  * Search for Spherelet, there should be logs regarding the current state. A few examples:
    * `For node host-12, setting step from configureKubeNode to beginStep``
    * `For node host-12, setting step from drainKubeNode to stopSphereletService``

Check /var/log/spherelet.log in the esxi host. An example:
  * `level=fatal msg="nodes \"172.16.0.40\" is forbidden: node \"localhost\" is not allowed to modify node \"172.16.0.40\""``

##### nodes \"172.16.0.40\" is forbidden: node \"localhost\" is not allowed to modify node \"172.16.0.40\"

Fixed using a proper hostname for the ESXi host.


## Force refresh of pinniped credentials

Remove/rename files in `~/.config/tanzu/pinniped`

## Retrieve HAProxy certificate

If the haproxy is deployed without a custom certificate, the self signed certificate generated during the deployment can be found in `/etc/haproxy/server.crt`.
