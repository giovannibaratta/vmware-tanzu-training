resource "vault_policy" "kv_ro" {
  name = "kv-ro"

  policy = templatefile("${path.module}/files/policies/template/kv-read-only.hcl.tpl", {
    kv_path = vault_mount.kvv2.path
  })
}

resource "vault_policy" "kv_rw" {
  name = "kv-rw"

  policy = templatefile("${path.module}/files/policies/template/kv-read-write.hcl.tpl", {
    kv_path = vault_mount.kvv2.path
  })
}