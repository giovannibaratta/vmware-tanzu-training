resource "random_password" "vm_root_user" {
  length           = 6
  upper            = false
  special          = false
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "random_password" "db_root_password" {
  length           = 16
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

locals {
  harbor_fqdn = "harbor.${var.domain}"

  harbor_playbook = templatefile("${path.module}/files/harbor-install-playbook.yaml", {
    harbor_fqdn : local.harbor_fqdn
  })

  harbor_conf = templatefile("${path.module}/files/harbor-config.yml.tftpl", {
    fqdn : local.harbor_fqdn
    admin_password : random_password.admin_password.result
    db_root_password : random_password.db_root_password.result
  })

  # User data rendered using the Terraform provider produce an invalid configuration
  # See https://github.com/hashicorp/terraform-provider-cloudinit/issues/165
  harbor_user_data = templatefile("${path.module}/files/harbor-cloud-config.yml.tftpl", {
    fqdn : local.harbor_fqdn
    password : random_password.vm_root_user.result
    authorized_key : var.vm_authorized_key
    harbor_install_playbook : base64encode(local.harbor_playbook)
    harbor_conf : base64encode(local.harbor_conf)
    harbor_service : base64encode(file("${path.module}/files/harbor-systemd.service"))
  })
}

resource "vsphere_virtual_machine" "harbor" {
  name             = "harbor"
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
      "user-data"   = base64encode(local.harbor_user_data)
      "public-keys" = var.vm_authorized_key
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, clone]
  }
}
