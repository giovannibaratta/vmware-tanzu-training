module "harbor" {
  count  = local.deploy_harbor ? 1 : 0
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/harbor-standalone?ref=harbor-standalone-v0.0.4&depth=1"

  vm_authorized_key = var.vm_authorized_key
  domain            = var.domain
  vsphere = {
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.services.id
    network_id       = data.vsphere_network.mgmt_segment.id
    template_id      = vsphere_content_library_item.ubuntu2204.id
  }
}

resource "harbor_project" "projects" {
  for_each = var.registry_projects

  name                   = each.value
  public                 = true
  vulnerability_scanning = false

  lifecycle {
    precondition {
      condition     = local.deploy_harbor
      error_message = "Harbor service must be enabled to enable the projects"
    }
  }

  depends_on = [module.harbor]
}
