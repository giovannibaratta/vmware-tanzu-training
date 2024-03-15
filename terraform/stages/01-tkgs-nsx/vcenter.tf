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

resource "vsphere_content_library" "templates" {
  name            = "Templates"
  storage_backing = [data.vsphere_datastore.datastore.id]
}

resource "vsphere_content_library_item" "ubuntu2204" {
  name        = "ubuntu-22.04"
  description = "Ubuntu Server LTS OVA Template"
  file_url    = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  library_id  = vsphere_content_library.templates.id

  # If you want to manually upload the image from the UI, import the terraform resource and
  # uncomment the following lines
  # lifecycle {
  #   ignore_changes = [ 
  #     # Ignore the properties becasue if the file has been uploaded manually and then imported
  #     # into terraform it will force a replacement
  #     file_url,
  #     description
  #    ]
  # }
}
