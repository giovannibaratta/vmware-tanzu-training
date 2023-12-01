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