resource "vsphere_virtual_machine" "keycloak" {
  name = "keycloak"

  resource_pool_id = vsphere_resource_pool.mgmt.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 2048
  guest_id = "other5xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.mgmt.id
  }

  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_content_library_item.debian_goldenimage.id

    customize {
      # Use DHCP
      network_interface {}
      #
      linux_options {
        host_name = "keycloak"
        domain    = "local.lan"
      }
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode]
  }
}