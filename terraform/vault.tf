module "vault_cluster" {
  source = "./modules/vault"

  domain = "gkube.it"
  num_nodes = var.vault.num_instances
  vip = var.vault.vip

  vsphere = {
    resource_pool_id = vsphere_resource_pool.mgmt.id
    datastore_id     = data.vsphere_datastore.datastore.id
    port_group_id    = vsphere_distributed_port_group.mgmt_pg_1.id
    template_id      = data.vsphere_content_library_item.debian_goldenimage.id
  }

  generate_certificates = true
  certificate_dns_challenge_token = var.desec_token
  register_dns          = true
  deploy_load_balancer = true
  avi = {
    cloud_id = data.avi_cloud.vcenter.id
  }
}
