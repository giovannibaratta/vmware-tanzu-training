resource "random_password" "vm_root_user" {
  length           = 6
  upper            = false
  special          = false
  override_special = "#%+=!"
}

locals {
  hostname = split(".", var.fqdn)[0]

  # Fallback to a random generated password if the user didn't provide one
  root_password = coalesce(var.root_password, random_password.vm_root_user.result)

  # User data rendered using the Terraform provider produce an invalid configuration
  # See https://github.com/hashicorp/terraform-provider-cloudinit/issues/165
  default_user_data = templatefile("${path.module}/files/default-cloud-config.yml.tftpl", {
    hostname : local.hostname
    fqdn : var.fqdn
    root_password : local.root_password
    authorized_key : var.vm_authorized_key
    setup_playbook : var.ansible_playbook
    write_files : var.cloud_init_write_files
    galaxy_actions : var.ansible_galaxy_actions
  })

  # Fallback to the default user_data if the user didn't provide one
  user_data = coalesce(var.cloud_init, local.default_user_data)
}

resource "vsphere_virtual_machine" "vm" {
  name = split(".", var.fqdn)[0]

  resource_pool_id = var.vsphere.resource_pool_id
  datastore_id     = var.vsphere.datastore_id
  num_cpus         = var.vm_specs.cpu
  memory           = var.vm_specs.memory

  clone {
    template_uuid = var.vsphere.template_id

    # Do not customize the clone when using user-data.
    # See https://github.com/vmware/open-vm-tools/issues/684,
    # https://github.com/canonical/cloud-init/issues/4188,
    # https://github.com/canonical/cloud-init/issues/4404
  }

  # This is required to load vApp properties correctly
  cdrom {
    client_device = true
  }

  disk {
    label            = "disk0"
    size             = var.vm_specs.disk_size
    thin_provisioned = true
  }

  network_interface {
    network_id = var.vsphere.network_id
  }

  vapp {
    properties = {
      "user-data" = base64encode(local.user_data)
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, clone]
  }
}
