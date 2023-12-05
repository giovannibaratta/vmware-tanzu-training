output "nodes" {
  value = {
    for key, value in local.node_specs: key => {
      id = value.id
      name = vsphere_virtual_machine.nodes[key].name
      ip = vsphere_virtual_machine.nodes[key].default_ip_address
      ssl = try({
        key = acme_certificate.nodes[key].private_key_pem
        certificate = acme_certificate.nodes[key].certificate_pem
        certificate_issuer = acme_certificate.nodes[key].issuer_pem
      }, null)
    }
  }
}

output "cluster" {
  value = {
    name = random_pet.cluster_name.id
    api_fqdn = coalesce(var.register_dns ? "vault.${var.domain}" : null, var.vip, vsphere_virtual_machine.nodes[0].default_ip_address)
  }
}