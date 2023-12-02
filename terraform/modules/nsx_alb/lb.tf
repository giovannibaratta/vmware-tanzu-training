# VIP that clients can use to contact service
resource "avi_vsvip" "vip" {
  name      = "${var.service_name}-vip"
  cloud_ref = var.cloud_id
  vip {
    vip_id = "${var.service_name}-vip-0"
    ip_address {
      type = "V4"
      addr = var.vip.ip
    }
  }
}

# SSL profiles used by the service engines to communicate with backends
resource "avi_sslprofile" "pool_profile" {
  name = "${var.service_name}-pool-ssl-profile"

  accepted_versions {
    type = "SSL_VERSION_TLS1_2"
  }
}

resource "avi_healthmonitor" "hm" {
  name          = "${var.service_name}-hm"
  type          = "HEALTH_MONITOR_HTTPS"
  failed_checks = 2
  https_monitor {
    http_request       = var.https_monitor_request
    http_response_code = ["HTTP_2XX"]
  }

  receive_timeout   = 5
  successful_checks = 1
}

resource "avi_pool" "pool" {
  name                = "${var.service_name}-pool"
  cloud_ref           = var.cloud_id
  default_server_port = 8200
  health_monitor_refs = [avi_healthmonitor.hm.id]

  # Each deployed VM is part of the pool
  dynamic "servers" {
    for_each = toset(var.pool_ips)
    content {
      ip {
        type = "V4"
        addr = servers.value
      }
      hostname = servers.value
    }
  }

  ssl_profile_ref = avi_sslprofile.pool_profile.id
}

# Issuer of VIP certificate
resource "avi_sslkeyandcertificate" "vip_chain" {
  name = "${var.service_name}-ssl-chain"

  certificate {
    self_signed = false
    certificate = var.vip.ssl.certificate_ca
  }

  type = "SSL_CERTIFICATE_TYPE_CA"
}

# Certificate exposed by the VIP
resource "avi_sslkeyandcertificate" "vip" {
  name = "${var.service_name}-ssl"
  key  = var.vip.ssl.private_key

  certificate {
    self_signed = false
    certificate = var.vip.ssl.certificate
  }

  ca_certs {
    ca_ref = avi_sslkeyandcertificate.vip_chain.id
  }

  type = "SSL_CERTIFICATE_TYPE_VIRTUALSERVICE"
}

resource "avi_virtualservice" "service" {
  name                         = "${var.service_name}-vs"
  cloud_ref                    = var.cloud_id
  pool_ref                     = avi_pool.pool.id
  ssl_key_and_certificate_refs = [avi_sslkeyandcertificate.vip.id]
  vsvip_ref                    = avi_vsvip.vip.id

  services {
    port           = 443
    port_range_end = 443
    enable_ssl     = true
  }
}
