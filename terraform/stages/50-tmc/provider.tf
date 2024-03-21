provider "tanzu-mission-control" {
  endpoint = var.tmc.endpoint

  self_managed {
    oidc_issuer = var.tmc.oidc_issuer
    username    = var.tmc.username
    password    = var.tmc.password
  }

  ca_cert = var.tmc.ca_cert
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.supervisor_context_name
}

locals {
  tap_kubeconfig    = yamldecode(base64decode(tanzu-mission-control_tanzu_kubernetes_cluster.tap.spec.0.kubeconfig))
  tap_env_variables = { for item in local.tap_kubeconfig.users.0.user.exec.env : item.name => item.value }
}

provider "kubernetes" {
  alias = "tap_cluster"

  host                   = local.tap_kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.tap_kubeconfig.clusters.0.cluster.certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "tmc"
    args        = ["cluster", "generate-token-v2"]
    env = {
      "CLUSTER_UID"       = local.tap_env_variables.CLUSTER_UID
      "CLUSTER_RID_V2"    = local.tap_env_variables.CLUSTER_RID_V2
      "CLUSTER_ENDPOINT"  = local.tap_env_variables.CLUSTER_ENDPOINT
      "CLUSTER_CA_BUNDLE" = local.tap_env_variables.CLUSTER_CA_BUNDLE
      "TMC_ENDPOINT"      = local.tap_env_variables.TMC_ENDPOINT
      "TMC_SELF_MANAGED"  = local.tap_env_variables.TMC_SELF_MANAGED
    }
  }
}
