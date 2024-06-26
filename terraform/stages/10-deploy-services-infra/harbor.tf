locals {
  registry_fqdn = "registry.${var.domain}"
}

resource "tls_private_key" "registry" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "registry" {
  private_key_pem = tls_private_key.registry.private_key_pem

  subject {
    common_name = "Registry"
  }

  dns_names = [local.registry_fqdn]
}

resource "tls_locally_signed_cert" "registry" {
  cert_request_pem   = tls_cert_request.registry.cert_request_pem
  ca_private_key_pem = var.ca_private_key
  ca_cert_pem        = var.ca_certificate

  validity_period_hours = 24 * 365

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}


module "harbor" {
  count  = local.deploy_harbor ? 1 : 0
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/harbor-standalone?ref=harbor-standalone-v2.1.0&depth=1"

  vm_authorized_key = var.vm_authorized_key

  fqdn = local.registry_fqdn

  vsphere = {
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.services.id
    network_id       = data.vsphere_network.mgmt_segment.id
    template_id      = local.vm_template_id
  }

  tls = {
    private_key = base64encode(tls_private_key.registry.private_key_pem)
    certificate = base64encode(tls_locally_signed_cert.registry.cert_pem)
    ca_chain    = base64encode(tls_locally_signed_cert.registry.ca_cert_pem)
  }

  docker_daemon_options = var.docker_daemon_options
}
