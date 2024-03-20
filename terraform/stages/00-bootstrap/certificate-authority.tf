resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "Certificate Authority"
    organization = "Local Lab"
  }

  validity_period_hours = 24 * 365 * 5

  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "client_auth",
    "crl_signing",
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}
