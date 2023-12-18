####################################################################################################
# TKGm reference architecture
# https://docs.vmware.com/en/VMware-Tanzu-for-Kubernetes-Operations/2.3/tko-reference-architecture/GUID-reference-designs-tko-on-vsphere-nsx.html#network-architecture-8
####################################################################################################

####################################################################################################
# Reference to existing resources
####################################################################################################

data "nsxt_policy_edge_cluster" "edge" {
  display_name = "nsxt01cl01"
}

data "nsxt_policy_tier0_gateway" "t0" {
  display_name = "nsxt01-t0-tr"
}

data "nsxt_policy_transport_zone" "tkgm" {
  display_name = "nsxt01-overlay"
}

####################################################################################################
# T1 gateways
####################################################################################################

resource "nsxt_policy_tier1_gateway" "mgmt" {
  description  = "Tier-1 provisioned by Terraform"
  display_name = "mgmt"

  edge_cluster_path = data.nsxt_policy_edge_cluster.edge.path

  failover_mode             = "NON_PREEMPTIVE"
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_LB_VIP", "TIER1_LB_SNAT", "TIER1_DNS_FORWARDER_IP", "TIER1_IPSEC_LOCAL_ENDPOINT"]
  pool_allocation           = "ROUTING"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0.path
  dhcp_config_path          = nsxt_policy_dhcp_server.tkgm.path
}

resource "nsxt_policy_tier1_gateway" "alb_controller" {
  description  = "Tier-1 provisioned by Terraform"
  display_name = "alb-controller"

  edge_cluster_path = data.nsxt_policy_edge_cluster.edge.path

  failover_mode             = "NON_PREEMPTIVE"
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_LB_VIP", "TIER1_LB_SNAT", "TIER1_DNS_FORWARDER_IP", "TIER1_IPSEC_LOCAL_ENDPOINT"]
  pool_allocation           = "ROUTING"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0.path
  dhcp_config_path          = nsxt_policy_dhcp_server.tkgm.path
}

resource "nsxt_policy_tier1_gateway" "workload" {
  description  = "Tier-1 provisioned by Terraform"
  display_name = "workload"

  edge_cluster_path = data.nsxt_policy_edge_cluster.edge.path

  failover_mode             = "NON_PREEMPTIVE"
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_LB_VIP", "TIER1_LB_SNAT", "TIER1_DNS_FORWARDER_IP", "TIER1_IPSEC_LOCAL_ENDPOINT"]
  pool_allocation           = "ROUTING"
  tier0_path                = data.nsxt_policy_tier0_gateway.t0.path
  dhcp_config_path          = nsxt_policy_dhcp_server.tkgm.path
}

####################################################################################################
# Segments
####################################################################################################

resource "nsxt_policy_segment" "tkgm_mgmt" {
  nsx_id              = "tkgm-mgmt"
  display_name        = "tkgm-mgmt"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.mgmt.path

  subnet {
    cidr        = "192.168.40.1/24"
    dhcp_ranges = ["192.168.40.100-192.168.40.200"]

    dhcp_v4_config {
      server_address = "192.168.40.254/24"
      dns_servers    = ["10.220.136.2", "10.220.136.3"]
    }
  }
}

resource "nsxt_policy_segment" "tkgm_shared_services" {
  nsx_id              = "tkgm-shared-services"
  display_name        = "tkgm-shared-services"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.mgmt.path

  subnet {
    cidr        = "192.168.50.1/24"
    dhcp_ranges = ["192.168.50.100-192.168.50.200"]

    dhcp_v4_config {
      server_address = "192.168.50.254/24"
      dns_servers    = ["10.220.136.2", "10.220.136.3"]
    }
  }
}

resource "nsxt_policy_segment" "tkgm_mgmt_vip" {
  nsx_id              = "tkgm-mgmt-vip"
  display_name        = "tkgm-mgmt-vip"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.mgmt.path
  subnet {
    cidr = "192.168.80.1/24"
  }
}

resource "nsxt_policy_segment" "tkgm_workload_01" {
  nsx_id              = "tkgm-workload-01"
  display_name        = "tkgm-workload-01"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.workload.path

  subnet {
    cidr = "192.168.60.1/24"

    dhcp_ranges = ["192.168.60.100-192.168.60.200"]

    dhcp_v4_config {
      server_address = "192.168.60.254/24"
      dns_servers    = ["10.220.136.2", "10.220.136.3"]
    }
  }
}

resource "nsxt_policy_segment" "tkgm_workload_vip" {
  nsx_id              = "tkgm-workload-vip"
  display_name        = "tkgm-workload-vip"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.workload.path

  subnet {
    cidr = "192.168.70.1/24"

    dhcp_ranges = ["192.168.70.100-192.168.70.200"]

    dhcp_v4_config {
      server_address = "192.168.70.254/24"
      dns_servers    = ["10.220.136.2", "10.220.136.3"]
    }
  }
}

resource "nsxt_policy_segment" "alb_mgmt" {
  nsx_id              = "alb-mgmt"
  display_name        = "alb-mgmt"
  description         = "Terraform provisioned Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.tkgm.path
  connectivity_path   = nsxt_policy_tier1_gateway.alb_controller.path
  subnet {
    cidr = "192.168.10.1/24"
  }
}

####################################################################################################
# DHCP
####################################################################################################

resource "nsxt_policy_dhcp_server" "tkgm" {
  description       = "provisioned by Terraform"
  display_name      = "tkgm-dhcp"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge.path
}

####################################################################################################
# NAT
####################################################################################################

resource "nsxt_policy_nat_rule" "snat" {
  display_name        = "nat"
  action              = "SNAT"
  source_networks     = ["192.168.0.0/16"]
  translated_networks = ["10.220.6.192"]
  gateway_path        = data.nsxt_policy_tier0_gateway.t0.path
  rule_priority       = 0
  firewall_match      = "MATCH_INTERNAL_ADDRESS"
}