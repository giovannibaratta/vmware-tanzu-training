## Setup a single zone Supervisor cluster

The script uses yaml configurations files to initialize and configure a supervisor cluster.

The script performs the following steps:
* create a supervisor cluster if there is not an existing supervisor with the configured name
* Attach (or update) an identity provider if specified in the configuration file.

>  The script uses vCenter APIs to perform all the operations.

Example of invocation:
```sh
bash ./create-single-zone-supervisor.sh vcenter.local.lan 'administrator@vsphere.local' instances/supervisor-01.yml instances/supervisor-01-secrets.yaml
```

The script requires the following parameters:
1. vCenter server
1. vCenter username
1. main definition file containing all the configurations
1. Additional definition file containing the secrets

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

identityProvider:
  clientId: STRING
  displayName: STRING
  issuerURL: URL
  certificateAuthorityData: SERVER_CERT
```

The definition file containing the secrets has the following structure:

```yaml
haproxy:
  password: STRING

identityProvider:
  clientSecret: STRING
```

## Setup vSphere namespace

The script uses a yaml configuration file to configure one or more vSphere namespaces.

Example of invocation:
```sh
bash ./setup-namespaces.sh vcenter.local.lan 'administrator@vsphere.local' instances/supervisor-01.yml
```

The script requires the following parameters:
1. vCenter server
1. vCenter username
1. main definition file containing all the configurations

The definition file has the following structure:

```yaml
namespaces:
  - name: STRING
    supervisor: STRING
    storagePolicies:
      - STRING 1
      - STRING ...
    vmClasses:
      - STRING 1
      - STRING ...
```

## Environment variables
|VARIABLE|ALLOWED VALUES|Description|
|-|-|-|
|NO_VERIFY_SSL|TRUE|Do not validate the SSL cert when using vCenter APIs|
|VSPHERE_PWD|STRING|Do not ask for the vCenter password when running the script|
