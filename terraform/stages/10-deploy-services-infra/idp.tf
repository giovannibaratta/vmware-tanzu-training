locals {
  idp_fqdn = "idp.${var.domain}"
}

resource "tls_private_key" "idp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "idp" {
  private_key_pem = tls_private_key.idp.private_key_pem

  subject {
    common_name = "IDP"
  }

  dns_names = [local.idp_fqdn]
}

resource "tls_locally_signed_cert" "idp" {
  cert_request_pem   = tls_cert_request.idp.cert_request_pem
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

module "keycloak" {
  count  = local.depoy_keylock ? 1 : 0
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/keycloak?ref=keycloak-v0.0.5&depth=1"

  fqdn = local.idp_fqdn

  vm_authorized_key = var.vm_authorized_key

  vsphere = {
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = vsphere_resource_pool.services.id
    network_id       = data.vsphere_network.mgmt_segment.id
    template_id      = local.vm_template_id
  }

  tls = {
    private_key = base64encode(tls_private_key.idp.private_key_pem)
    certificate = base64encode(tls_locally_signed_cert.idp.cert_pem)
    ca_chain    = base64encode(tls_locally_signed_cert.idp.ca_cert_pem)
  }
}
