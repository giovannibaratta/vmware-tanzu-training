# Import existing vSphere references
data "vsphere_datacenter" "datacenter" {
  name = var.vcenter_data.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vcenter_data.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vcenter_data.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster_host_group" "compute" {
  name               = "compute"
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id
}

data "vsphere_network" "mgmt_segment" {
  name          = var.vcenter_data.mgmt_segment_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_resource_pool" "services" {
  name                    = "services"
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}

locals {
  use_existing_template = var.vm_template != null
}

resource "vsphere_content_library" "templates" {
  count           = local.use_existing_template ? 0 : 1
  name            = "Templates"
  storage_backing = [data.vsphere_datastore.datastore.id]
}

resource "vsphere_content_library_item" "ubuntu2204" {
  count       = local.use_existing_template ? 0 : 1
  name        = "ubuntu-22.04"
  description = "Ubuntu Server LTS OVA Template"
  file_url    = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  library_id  = vsphere_content_library.templates[0].id
}

data "vsphere_content_library" "library" {
  count = local.use_existing_template ? 1 : 0
  name  = var.vm_template.library_name
}

data "vsphere_content_library_item" "template" {
  count      = local.use_existing_template ? 1 : 0
  name       = var.vm_template.template_name
  type       = "ovf"
  library_id = data.vsphere_content_library.library.0.id
}

locals {
  vm_template_id = local.use_existing_template ? data.vsphere_content_library_item.template.0.id : vsphere_content_library_item.ubuntu2204.0.id
}
