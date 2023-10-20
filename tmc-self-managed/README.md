https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/1.0/tanzumc-sm-install/install-tmc-sm.html

If you are deploying an Harbor registry for the first time, you might need to upload some public available packages required for the installation to the private registry. See [this](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-35EB7EB7-7B4F-4C01-A4C5-551D8C0D4409.html) link for more details.

## FAQ

**<i> How to let the kapp-controller trust a self-signed certificate of the Harbor registry ?**

The certificate can be injected using a secret or a config map, see [here](https://carvel.dev/kapp-controller/docs/latest/controller-config/) for more details .