# Deploy standalone NSX ALB

1. Download OVF from https://portal.avipulse.vmware.com/software/nsx-alb/64eee2f251570a041eac191b
1. Install the OVF https://docs.vmware.com/en/VMware-NSX-Advanced-Load-Balancer/30.1/Installation-Guide/GUID-F1F9CD95-C9FF-4F6D-ACE8-D38E5A5FE04C.html
    > N.B. The VM takes quite a long time to boot up.
1. Create a content library in vSphere, it will be referenced in the next step
1. First setup of the controller https://docs.vmware.com/en/VMware-NSX-Advanced-Load-Balancer/30.1/Installation-Guide/GUID-52F8DF60-F149-48D0-BBBC-0BA2F47440DA.html
  - Do not enable DHCP if not available during cloud configuration
  - The network and IP address range are used by the service engines
1. After the configuration, a new OVF/OVA should appear in the content library (eg  30.1.1-9415-20230825.172021_vcenter_a229ee8c3c34)
1. A service engine group should also be created in infrastructure -> Cloud Resources -> Service Engine group
1. Add a network for the service engines in infrastructure -> Cloud Resources -> Networks