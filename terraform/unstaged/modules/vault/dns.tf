resource "desec_rrset" "node" {
  for_each = var.register_dns ? local.node_specs : {}

  domain  = var.domain
  subname = "vault-${each.value.id}"
  type    = "A"
  records = [vsphere_virtual_machine.nodes[each.key].default_ip_address]
  ttl     = 3600
}

resource "desec_rrset" "vip" {
  count = var.register_dns && var.vip != null ? 1 : 0

  domain  = var.domain
  subname = "vault"
  type    = "A"
  records = [ var.vip ]
  ttl     = 3600
}