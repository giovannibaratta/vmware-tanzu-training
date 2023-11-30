locals {
  vault_instances = 1
}

resource "vsphere_virtual_machine" "vault" {
  count = local.vault_instances

  name = "vault-${count.index}"

  resource_pool_id = vsphere_resource_pool.mgmt.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 2048
  guest_id = "other5xLinux64Guest"

  network_interface {
    network_id = vsphere_distributed_port_group.mgmt_pg_1.id
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
        host_name = "vault-${count.index}"
        domain    = "local.lan"
      }
    }
  }

  # Perma diff
  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode]
  }
}

# Generate DNS records for vault instances

resource "desec_rrset" "vault" {
  count = local.vault_instances

  domain = "gkube.it"
  subname = "vault-${count.index}"
  type = "A"
  records = [ vsphere_virtual_machine.vault[count.index].default_ip_address ]
  ttl = 3600
}

# Generate certificates for vault instances

resource "tls_private_key" "vault_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "vault" {
  account_key_pem = tls_private_key.vault_private_key.private_key_pem
  email_address   = "bargiovi@hotmail.it"
}

resource "acme_certificate" "vault_certificates" {
  count = local.vault_instances

  account_key_pem           = acme_registration.vault.account_key_pem
  common_name               = "vault-${count.index}.gkube.it"

  recursive_nameservers = ["1.1.1.1:53"]
  pre_check_delay = 30

  dns_challenge {
    provider = "desec"

    config = {
      DESEC_TOKEN = var.desec_token
      DESEC_PROPAGATION_TIMEOUT=600
    }
  }
}