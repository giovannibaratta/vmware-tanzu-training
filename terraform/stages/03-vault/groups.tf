resource "vault_identity_group" "kv_ro" {
  name     = "kv-ro"
  type     = "external"
  policies = [vault_policy.kv_ro.name]
}

resource "vault_identity_group" "kv_rw" {
  name     = "kv-rw"
  type     = "external"
  policies = [vault_policy.kv_rw.name]
}