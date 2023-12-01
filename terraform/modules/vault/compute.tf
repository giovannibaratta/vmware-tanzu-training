resource "vsphere_virtual_machine" "nodes" {
  for_each = local.node_specs

  name = "vault-${each.value.id}"

  resource_pool_id = var.vsphere.resource_pool_id
  datastore_id     = var.vsphere.datastore_id

  num_cpus = 1
  memory   = 4096
  guest_id = "other5xLinux64Guest"

  network_interface {
    network_id = var.vsphere.port_group_id
  }

  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = true
  }

  clone {
    template_uuid = var.vsphere.template_id

    customize {
      # Use DHCP
      network_interface {}
      #
      linux_options {
        host_name = "vault-${each.value.id}"
        domain    = var.domain
      }
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode]
  }
}