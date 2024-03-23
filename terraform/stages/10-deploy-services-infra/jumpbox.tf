module "jumpbox" {
  count  = local.deploy_jumpbox ? 1 : 0
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/jumpbox?ref=jumpbox-v0.0.3&depth=1"

  vm_authorized_key = var.vm_authorized_key
  domain            = var.domain
  vsphere = {
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.services.id
    network_id       = data.vsphere_network.mgmt_segment.id
    template_id      = local.vm_template_id
  }
}
