resource "random_password" "vm_root_user" {
  length           = 6
  upper            = false
  special          = false
  override_special = "#$%&*()=+[]{}<>:?"
}

locals {
  jumpbox = "jumpbox.${var.domain}"

  jumpbox_playbook = templatefile("${path.module}/files/jumpbox-setup-playbook.yaml", {
    jumpbox : local.jumpbox
  })

  # User data rendered using the Terraform provider produce an invalid configuration
  # See https://github.com/hashicorp/terraform-provider-cloudinit/issues/165
  jumpbox_user_data = templatefile("${path.module}/files/jumpbox-cloud-config.yml.tftpl", {
    fqdn : local.jumpbox
    password : random_password.vm_root_user.result
    authorized_key : var.vm_authorized_key
    setup_playbook : base64encode(local.jumpbox_playbook)
  })
}

resource "vsphere_virtual_machine" "jumpbox" {
  name             = "jumpbox"
  resource_pool_id = var.vsphere.resource_pool_id
  datastore_id     = var.vsphere.datastore_id

  num_cpus = 2
  memory   = 4096

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
    size             = 200
    thin_provisioned = true
  }

  network_interface {
    network_id = var.vsphere.network_id
  }

  vapp {
    properties = {
      "user-data"   = base64encode(local.jumpbox_user_data)
      "public-keys" = var.vm_authorized_key
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, clone]
  }
}
