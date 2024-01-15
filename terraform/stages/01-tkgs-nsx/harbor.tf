module "harbor" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/harbor-standalone?ref=harbor-standalone-v0.0.2&depth=1"

  vm_authorized_key = var.vm_authorized_key
  domain = var.domain
  vsphere = {
    datastore_id = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.harbor.id
    network_id = data.vsphere_network.mgmt_segment.id
    template_id = vsphere_content_library_item.ubuntu2204.id
  }
}