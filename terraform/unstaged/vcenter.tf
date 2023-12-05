data "vsphere_datacenter" "datacenter" {
  name = "dc01"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "vc01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "hosts" {
  for_each      = var.hosts
  name          = each.value
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_compute_cluster_host_group" "compute" {
  name               = "compute"
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id
  host_system_ids    = [for host in data.vsphere_host.hosts : host.id]
}

data "vsphere_network" "frontend" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_content_library" "templates" {
  name = "Templates"
}

data "vsphere_content_library_item" "debian_goldenimage" {
  name       = "debian-goldenimage-20231108-081404"
  type       = "ovf"
  library_id = data.vsphere_content_library.templates.id
}

resource "vsphere_resource_pool" "mgmt" {
  name                    = "mgmt"
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}

resource "vsphere_distributed_virtual_switch" "management" {
  name          = "management-vds"
  datacenter_id = data.vsphere_datacenter.datacenter.id

  dynamic "host" {
    for_each = data.vsphere_host.hosts
    content {
      host_system_id = host.value.id
    }
  }
}

resource "vsphere_distributed_port_group" "mgmt_pg_1" {
  name                            = "management-port-group-1"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.management.id

  vlan_id = 0
}

resource "vsphere_distributed_virtual_switch" "workload" {
  name          = "workload-vds"
  datacenter_id = data.vsphere_datacenter.datacenter.id

  dynamic "host" {
    for_each = data.vsphere_host.hosts
    content {
      host_system_id = host.value.id
    }
  }
}

resource "vsphere_distributed_port_group" "workload_pg_1" {
  name                            = "workload-port-group-1"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.workload.id

  vlan_id = 0
}