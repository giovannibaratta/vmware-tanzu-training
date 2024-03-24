locals {
  kubeconfig_yaml         = replace(var.kubeconfigs["mgmt/tmc-sm"], "\"", "")
  kubeconfig              = yamldecode(var.kubeconfigs["mgmt/tmc-sm"])
  tmc_cluster_server      = local.kubeconfig.clusters.0.cluster.server
  tmc_cluster_ca          = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  tmc_cluster_client_key  = base64decode(local.kubeconfig.users.0.user.client-key-data)
  tmc_cluster_client_cert = base64decode(local.kubeconfig.users.0.user.client-certificate-data)
}

provider "kubernetes" {
  host                   = local.tmc_cluster_server
  cluster_ca_certificate = local.tmc_cluster_ca
  client_key             = local.tmc_cluster_client_key
  client_certificate     = local.tmc_cluster_client_cert
}
