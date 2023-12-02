module "lb" {
  count = var.deploy_load_balancer ? 1 : 0
  source = "../nsx_alb"

  service_name = "vault"
  cloud_id = var.avi.cloud_id
  https_monitor_request = "GET /v1/sys/health?standbyok=true&perfstandbyok=true"

  vip = {
    ip = var.vip
    ssl = {
      private_key = acme_certificate.vip[0].private_key_pem
      certificate = acme_certificate.vip[0].certificate_pem
      certificate_ca = acme_certificate.vip[0].issuer_pem
    }
  }

  pool_ips = [ for node in vsphere_virtual_machine.nodes: node.default_ip_address ]
}
