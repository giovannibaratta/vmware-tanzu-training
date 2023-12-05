resource "vsphere_virtual_machine" "keycloak" {
  name = "keycloak"

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

resource "acme_certificate" "keycloak" {
  account_key_pem = acme_registration.main.account_key_pem
  common_name     = "keycloak.${var.domain}"

  recursive_nameservers = ["1.1.1.1:53"]
  pre_check_delay       = 30

  dns_challenge {
    provider = "desec"

    config = {
      DESEC_TOKEN               = var.desec_token
      DESEC_PROPAGATION_TIMEOUT = 600
    }
  }
}

resource "desec_rrset" "keycloak" {
  domain  = var.domain
  subname = "keycloak"
  type    = "A"
  records = [vsphere_virtual_machine.keycloak.default_ip_address]
  ttl     = 3600
}