vsphere_server = "vcenter.local.lan"

deployments = {
  haproxy = true
  minio = true
}

hosts          = ["172.16.0.40"]

haproxy_specs = {
  hostname    = "haproxy.local.lan"
  user        = "haproxy"
  nameservers = "172.16.0.48,1.1.1.1,8.8.8.8"

  management = {
    gateway = "172.17.0.1"
    ip_cidr = "172.17.0.3/16"
  }

  workload = {
    gateway = "172.18.0.1"
    ip_cidr = "172.18.0.2/16"
  }

  frontend = {
    gateway = "172.16.0.48"
    ip_cidr = "172.16.0.200/16"
  }

  service_cidr = "172.16.100.0/24"
}

avi = {
  controller = "172.17.0.30"
  username = "admin"
  version = "30.1.1"
  tenant = "admin"
  cloud_name = "vcenter-home-lab"
}

vault = {
  vip = "172.16.200.2"
  num_instances = 3
}

domain = "gkube.it"