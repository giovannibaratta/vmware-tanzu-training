# Create single zone Supervisor cluster

The script uses yaml configurations files to initialize a supervisor cluster. The cluster is created using the vCenter APIs, a minimal validation is performed on the input parameters.

```sh
bash ./create-single-zone-supervisor.sh vcenter.local.lan 'administrator@vsphere.local' instances/supervisor-01.yml instances/supervisor-01-secrets.yaml
```

The parameters are the vCenter server, vCenter username, the main definition file and the definition file containing secrets.

The script makes the following assumptions:
* vDS are used instead of NSX-T
* haproxy proxy is used for load balancing
* the supervisor is deployed in a single zone

### Definition files

The main definition file has the following structure:

```yaml
cluster: CLUSTER_NAME
supervisorName: SUPERVISOR_NAME
zone: ZONE_ID
storagePolicy: STORAGE_POLICY_NAME

supervisorControlPlane:
  portGroupName: PORT_GROUP_NAME
  gatewayCidr: IP/NETMASK
  firstIp: IP

workloadClusters:
  portGroupName: PORT_GROUP_NAME
  gatewayCidr: IP/NETMASK
  firstIp: IP
  contiguousUsableIps: INTEGER

services:
  firstIp: IP
  contiguousUsableIps: INTEGER

shared:
  ntp: IP_OR_FQDN
  dns: IP_OR_FQDN

haproxy:
  user: string
  server: IP_OR_FQDN:PORT
  certificate: SERVER_CERT
```

The definition file containing the secrets has the following structure:

```yaml
haproxy:
  password: STRING
```

### Environment variables
|VARIABLE|ALLOWED VALUES|Description|
|-|-|-|
|NO_VERIFY_SSL|TRUE|Do not validate the SSL cert when using vCenter APIs|
|VSPHERE_PWD|STRING|Do not ask for the vCenter password when running the script|
