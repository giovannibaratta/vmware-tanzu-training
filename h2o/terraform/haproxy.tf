# Ref https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-installation-configuration/GUID-5673269F-C147-485B-8706-65E4A87EB7F0.html#GUID-D84AE530-B577-45E0-9DEB-FCD6B75308E6__GUID-A387D97F-B0E5-4E6C-9240-A89D2F9C1DAF
resource "vsphere_virtual_machine" "haproxy" {
  count = var.deploy_haproxy ? 1 : 0
  name  = "haproxy"

  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = tolist(vsphere_compute_cluster_host_group.compute.host_system_ids)[0]
  resource_pool_id = vsphere_resource_pool.mgmt.id

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    remote_ovf_url            = "https://cdn.haproxy.com/download/haproxy/vsphere/ova/haproxy-v0.2.0.ova"
    disk_provisioning         = "thin"
    ip_protocol               = "IPV4"
    ip_allocation_policy      = "STATIC_MANUAL"
    deployment_option         = "frontend" # Value retrieved from the OVF
    enable_hidden_properties  = true

    ovf_network_map = {
      Management = data.vsphere_network.mgmt.id
      Workload   = data.vsphere_network.workload.id
      Frontend   = data.vsphere_network.frontend.id
    }
  }

  network_interface {
    network_id  = data.vsphere_network.mgmt.id
    ovf_mapping = "Management"
  }

  network_interface {
    network_id  = data.vsphere_network.workload.id
    ovf_mapping = "Workload"
  }

  network_interface {
    network_id  = data.vsphere_network.frontend.id
    ovf_mapping = "Frontend"
  }

  # Values retrieved from the OVF
  vapp {
    properties = {
      "root_pwd"           = var.haproxy_sensitive_specs.root_pwd
      "permit_root_login"  = "True"
      "hostname"           = var.haproxy_specs.hostname
      "nameservers"        = var.haproxy_specs.nameservers
      "management_ip"      = var.haproxy_specs.management.ip_cidr
      "management_gateway" = var.haproxy_specs.management.gateway
      "workload_ip"        = var.haproxy_specs.workload.ip_cidr
      "workload_gateway"   = var.haproxy_specs.workload.gateway
      "frontend_ip"        = var.haproxy_specs.frontend.ip_cidr
      "frontend_gateway"   = var.haproxy_specs.frontend.gateway
      "service_ip_range"   = var.haproxy_specs.service_cidr
      "haproxy_user"       = var.haproxy_specs.user
      "haproxy_pwd"        = var.haproxy_sensitive_specs.user_pwd
    }
  }

  lifecycle {
    ignore_changes = [ept_rvi_mode, hv_mode, vapp]
    precondition {
      condition     = var.haproxy_specs != null && var.haproxy_sensitive_specs != null
      error_message = "haproxy_specs and haproxy_sensitive_specs must be defined"
    }
  }
}