## AdmissionConfiguration

The `AdmissionConfiguration` is hardcoded in the ClusterClass shipped with the supervisor. If [setting the security annotations at the namespace level](https://kubernetes.io/docs/tutorials/security/ns-level-pss/) is not enough, a custom class can be created.

> If using TKG 2.3+ with Cluster APIs, the configuration can be set without creating a custom class https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.4/using-tkg/workload-security-psa.html.