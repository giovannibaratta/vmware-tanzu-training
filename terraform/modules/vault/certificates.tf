resource "tls_private_key" "account_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "vault" {
  count = var.generate_certificates ? 1 : 0
  account_key_pem = tls_private_key.account_private_key.private_key_pem
  email_address   = "bargiovi@hotmail.it"
}

resource "acme_certificate" "nodes" {
  for_each = var.generate_certificates ? local.node_specs : {}

  account_key_pem = acme_registration.vault[0].account_key_pem
  common_name     = "vault-${each.value.id}.${var.domain}"

  recursive_nameservers = ["1.1.1.1:53"]
  pre_check_delay       = 30

  dns_challenge {
    provider = "desec"

    config = {
      DESEC_TOKEN               = var.certificate_dns_challenge_token
      DESEC_PROPAGATION_TIMEOUT = 600
    }
  }
}

resource "acme_certificate" "vip" {
  count = var.generate_certificates ? 1 : 0

  account_key_pem = acme_registration.vault[0].account_key_pem
  common_name     = "vault.${var.domain}"

  recursive_nameservers = ["1.1.1.1:53"]
  pre_check_delay       = 30

  dns_challenge {
    provider = "desec"

    config = {
      DESEC_TOKEN               = var.certificate_dns_challenge_token
      DESEC_PROPAGATION_TIMEOUT = 600
    }
  }
}
