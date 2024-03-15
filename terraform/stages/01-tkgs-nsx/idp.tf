module "keycloak" {
  count  = local.depoy_keylock ? 1 : 0
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/keycloak?ref=keycloak-v0.0.1&depth=1"

  fqdn = "keycloak.${var.domain}"

  vm_authorized_key = var.vm_authorized_key

  vsphere = {
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.services.id
    network_id       = data.vsphere_network.mgmt_segment.id
    template_id      = vsphere_content_library_item.ubuntu2204.id
  }
}
