# VM used to access the isolated networks
resource "vsphere_virtual_machine" "jumpbox" {
  name = "jumpbox"

  resource_pool_id = vsphere_resource_pool.tkgm.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 2048
  guest_id = "other5xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.user_workload.id
    ovf_mapping = "Network adapter 1"
  }

  network_interface {
    network_id = data.vsphere_network.tkgm_mgmt.id
  }

  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_content_library_item.debian_goldenimage.id

    customize {
      network_interface {
      }

      network_interface {
      }

      linux_options {
        host_name = "jumpbox"
        domain    = "local.lan"
      }
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, clone]
  }
}

# VM used to initiate the installation of TKGm
resource "vsphere_virtual_machine" "tgkm_bootstrap" {
  name = "tkgm-bootstrap"

  resource_pool_id = vsphere_resource_pool.tkgm.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory =  16384
  guest_id = "other5xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.tkgm_mgmt.id
  }

  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_content_library_item.debian_goldenimage.id

    customize {
       network_interface {
      }

      linux_options {
        host_name = "tkgm-bootstrap"
        domain    = "local.lan"
      }
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, clone]
  }
}
