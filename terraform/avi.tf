locals {
  avi = merge(var.avi, var.avi_sensitive)
}

data "avi_cloud" "vcenter" {
  name = local.avi.cloud_name
}

# VIP that clients can use to contact Vault
resource "avi_vsvip" "vault" {
  name      = "vault-vip"
  cloud_ref = data.avi_cloud.vcenter.id
  vip {
    vip_id = "vault-vip-0"
    ip_address {
      type = "V4"
      addr = var.vault.vip
    }
  }
}

# SSL profiles used by the service engines to communicate with backends
resource "avi_sslprofile" "vault" {
  name = "vault-pool-ssl-profile"

  accepted_versions {
    type = "SSL_VERSION_TLS1_2"
  }
}

resource "avi_healthmonitor" "vault" {
  name = "vault-hm"
  type = "HEALTH_MONITOR_HTTPS"
  failed_checks = 2
  https_monitor {
    http_request = "GET /v1/sys/health?standbyok=true&perfstandbyok=true"
    http_response_code = [ "HTTP_2XX" ]
  }

  receive_timeout = 5
  successful_checks = 1
}

# Vault backend
resource "avi_pool" "vault" {
  name                = "vault-pool"
  cloud_ref           = data.avi_cloud.vcenter.id
  default_server_port = 8200
  health_monitor_refs = [ avi_healthmonitor.vault.id ]

  # Each deployed VM is part of the pool
  dynamic "servers" {
    for_each = vsphere_virtual_machine.vault
    content {
      ip {
        type = "V4"
        addr = servers.value.default_ip_address
      }
    }
  }

  ssl_profile_ref = avi_sslprofile.vault.id
}

# Certificate exposed by the VIP
resource "avi_sslkeyandcertificate" "vault" {
  name = "vault-ssl"
  key  = acme_certificate.vault_vip_certificate.private_key_pem
  certificate {
    self_signed = false
    certificate = acme_certificate.vault_vip_certificate.certificate_pem
  }
  type = "SSL_CERTIFICATE_TYPE_VIRTUALSERVICE"
}

resource "avi_virtualservice" "vault" {
  name                         = "vault-vs"
  cloud_ref                    = data.avi_cloud.vcenter.id
  pool_ref                     = avi_pool.vault.id
  ssl_key_and_certificate_refs = [ avi_sslkeyandcertificate.vault.id ]
  vsvip_ref                    = avi_vsvip.vault.id

  services {
    port           = 443
    enable_ssl     = true
  }
}
