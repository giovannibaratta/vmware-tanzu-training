data "vsphere_datacenter" "datacenter" {
  name = "vc01"
}

data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "vc01cl01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_content_library" "templates" {
  name = "Templates"
}

data "vsphere_content_library_item" "debian_goldenimage" {
  name       = "debian-goldenimage-20231214-153836"
  type       = "ovf"
  library_id = data.vsphere_content_library.templates.id
}

resource "vsphere_resource_pool" "tkgm" {
  name                    = "tgkm"
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}

data "vsphere_network" "tkgm_mgmt" {
  name          = "tkgm-mgmt"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "user_workload" {
  name          = "user-workload"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}