# Environment

Networking is based on vDS and haproxy for load balancing.

A pfsense appliance used for creating different networks. The pfsense appliance provides DHCP and NTP services.

vSphere version: 8

## IPs allocation

Example of IPs allocations:

|Network|IP/CIDRs|Used for|
|-|-|-|
|Management network|172.17.0.0/24|Supervisors nodes, haproxy, vCenter|
|Workload network|172.18.0.0/24|Workload clusters nodes|
|LB range frontend network|172.16.5.0/24|LoadBalancer services|
 

## Notes

* If the haproxy is deployed without a custom certificate, the self signed certificate generated during the deployment can be found in `/etc/haproxy/server.crt`.
Access the supervisor nodes: https://mappslearning.wordpress.com/2021/12/01/ssh-login-into-vsphere-with-tanzu-supervisor-cluster-nodes/
