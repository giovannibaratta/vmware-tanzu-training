# TKG clusters

The folder contains the definition of different clusters needed to implement the standard multi-cluster 
architecture.

1. Connect to the management cluster
1. `tanzu cluster create -f <PROFILE>-cluster-values.yaml`` -n tap

> The clusters use a cluster plan of type DEV

## Additional resources

[Reference architecture](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap-reference-architecture/GUID-reference-designs-tap-architecture-planning.html)

[Networking](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap-reference-architecture/GUID-reference-designs-tap-networking.html)