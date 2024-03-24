provider "tanzu-mission-control" {
  endpoint = "tmc.${var.domain}"

  self_managed {
    oidc_issuer = "pinniped-supervisor.tmc.${var.domain}"
    username    = var.tmc_admin_user.username
    password    = var.tmc_admin_user.password
  }

  ca_cert = var.ca_certificate
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.supervisor_context_name
}

locals {
  tap_view_kubeconfig    = yamldecode(base64decode(tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.spec.0.kubeconfig))
  tap_view_env_variables = { for item in local.tap_view_kubeconfig.users.0.user.exec.env : item.name => item.value }

  tap_build_kubeconfig    = yamldecode(base64decode(tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.spec.0.kubeconfig))
  tap_build_env_variables = { for item in local.tap_build_kubeconfig.users.0.user.exec.env : item.name => item.value }

  tap_iterate_kubeconfig    = yamldecode(base64decode(tanzu-mission-control_tanzu_kubernetes_cluster.tap_iterate.spec.0.kubeconfig))
  tap_iterate_env_variables = { for item in local.tap_iterate_kubeconfig.users.0.user.exec.env : item.name => item.value }

  tap_run_kubeconfig    = yamldecode(base64decode(tanzu-mission-control_tanzu_kubernetes_cluster.tap_run.spec.0.kubeconfig))
  tap_run_env_variables = { for item in local.tap_run_kubeconfig.users.0.user.exec.env : item.name => item.value }
}

provider "kubernetes" {
  alias = "tap_view_cluster"

  host                   = local.tap_view_kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.tap_view_kubeconfig.clusters.0.cluster.certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "tmc"
    args        = ["cluster", "generate-token-v2"]
    env = {
      "CLUSTER_UID"       = local.tap_view_env_variables.CLUSTER_UID
      "CLUSTER_RID_V2"    = local.tap_view_env_variables.CLUSTER_RID_V2
      "CLUSTER_ENDPOINT"  = local.tap_view_env_variables.CLUSTER_ENDPOINT
      "CLUSTER_CA_BUNDLE" = local.tap_view_env_variables.CLUSTER_CA_BUNDLE
      "TMC_ENDPOINT"      = local.tap_view_env_variables.TMC_ENDPOINT
      "TMC_SELF_MANAGED"  = local.tap_view_env_variables.TMC_SELF_MANAGED
    }
  }
}

provider "kubernetes" {
  alias = "tap_build_cluster"

  host                   = local.tap_build_kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.tap_build_kubeconfig.clusters.0.cluster.certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "tmc"
    args        = ["cluster", "generate-token-v2"]
    env = {
      "CLUSTER_UID"       = local.tap_build_env_variables.CLUSTER_UID
      "CLUSTER_RID_V2"    = local.tap_build_env_variables.CLUSTER_RID_V2
      "CLUSTER_ENDPOINT"  = local.tap_build_env_variables.CLUSTER_ENDPOINT
      "CLUSTER_CA_BUNDLE" = local.tap_build_env_variables.CLUSTER_CA_BUNDLE
      "TMC_ENDPOINT"      = local.tap_build_env_variables.TMC_ENDPOINT
      "TMC_SELF_MANAGED"  = local.tap_build_env_variables.TMC_SELF_MANAGED
    }
  }
}

provider "kubernetes" {
  alias = "tap_iterate_cluster"

  host                   = local.tap_iterate_kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.tap_iterate_kubeconfig.clusters.0.cluster.certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "tmc"
    args        = ["cluster", "generate-token-v2"]
    env = {
      "CLUSTER_UID"       = local.tap_iterate_env_variables.CLUSTER_UID
      "CLUSTER_RID_V2"    = local.tap_iterate_env_variables.CLUSTER_RID_V2
      "CLUSTER_ENDPOINT"  = local.tap_iterate_env_variables.CLUSTER_ENDPOINT
      "CLUSTER_CA_BUNDLE" = local.tap_iterate_env_variables.CLUSTER_CA_BUNDLE
      "TMC_ENDPOINT"      = local.tap_iterate_env_variables.TMC_ENDPOINT
      "TMC_SELF_MANAGED"  = local.tap_iterate_env_variables.TMC_SELF_MANAGED
    }
  }
}

provider "kubernetes" {
  alias = "tap_run_cluster"

  host                   = local.tap_run_kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.tap_run_kubeconfig.clusters.0.cluster.certificate-authority-data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "tmc"
    args        = ["cluster", "generate-token-v2"]
    env = {
      "CLUSTER_UID"       = local.tap_run_env_variables.CLUSTER_UID
      "CLUSTER_RID_V2"    = local.tap_run_env_variables.CLUSTER_RID_V2
      "CLUSTER_ENDPOINT"  = local.tap_run_env_variables.CLUSTER_ENDPOINT
      "CLUSTER_CA_BUNDLE" = local.tap_run_env_variables.CLUSTER_CA_BUNDLE
      "TMC_ENDPOINT"      = local.tap_run_env_variables.TMC_ENDPOINT
      "TMC_SELF_MANAGED"  = local.tap_run_env_variables.TMC_SELF_MANAGED
    }
  }
}