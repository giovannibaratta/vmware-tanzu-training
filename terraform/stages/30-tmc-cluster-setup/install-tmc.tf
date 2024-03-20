# Configure Kapp controller to trust the private registry
resource "kubernetes_secret_v1" "kapp_controller_config" {
  count = var.add_trust_to_kapp_controller ? 1 : 0

  metadata {
    name      = "kapp-controller-config"
    namespace = "tkg-system"
  }

  data = {
    caCerts = var.private_registry_ca
  }

  type = "Opaque"
}

resource "terraform_data" "restart_kapp_controller" {
  count = var.add_trust_to_kapp_controller ? 1 : 0

  triggers_replace = [
    kubernetes_secret_v1.kapp_controller_config.0.metadata.0.uid
  ]

  provisioner "local-exec" {
    command    = "kubectl delete pod -n tkg-system -l app=kapp-controller"
    on_failure = fail
    environment = {
      "KUBECONFIG" = var.tmc_kubeconfig
    }
  }

  depends_on = [kubernetes_secret_v1.kapp_controller_config]
}

# Install TMC
resource "kubernetes_manifest" "tmc_repository" {
  manifest = yamldecode(templatefile("${path.module}/files/package-repo-tmc-sm.yaml.tpl", {
    tmc_repo_ref = var.tmc_repo_ref
  }))

  depends_on = [terraform_data.restart_kapp_controller]
}

resource "kubernetes_service_account_v1" "tmc_install" {

  metadata {
    name      = "tanzu-mission-control-tkg-system-sa"
    namespace = "tkg-system"

    annotations = {
      "packaging.carvel.dev/package"       = "tmc-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "tmc-tkg-system"
    }
  }
}

resource "kubernetes_cluster_role_v1" "tmc_install" {

  metadata {
    name = "tanzu-mission-control-tkg-system-cluster-role"

    annotations = {
      "packaging.carvel.dev/package"       = "tmc-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "tmc-tkg-system"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "tmc_install" {

  metadata {
    name = "tanzu-mission-control-tkg-system-cluster-rolebinding"

    annotations = {
      "packaging.carvel.dev/package"       = "tmc-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "tmc-tkg-system"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.tmc_install.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.tmc_install.metadata.0.name
    namespace = kubernetes_service_account_v1.tmc_install.metadata.0.namespace
  }
}

resource "kubernetes_secret_v1" "tmc_values" {

  metadata {
    name      = "tanzu-mission-control-tkg-system-values"
    namespace = "tkg-system"

    annotations = {
      "packaging.carvel.dev/package"       = "tmc-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "tmc-tkg-system"
    }
  }

  data = {
    "values.yaml" = var.tmc_values
  }

  type = "Opaque"
}

resource "kubernetes_namespace_v1" "tmc_local" {
  metadata {
    name = "tmc-local"
    labels = {
      // TMC v1.1.0 requires permissions that are not allowed in policies stricter than "privileged"
      "pod-security.kubernetes.io/enforce" : "privileged"
    }
  }
}

resource "kubernetes_manifest" "tmc_package_install" {
  manifest = yamldecode(file("${path.module}/files/package-install-tmc-sm.yaml"))

  depends_on = [
    kubernetes_manifest.tmc_repository,
    kubernetes_secret_v1.tmc_values,
    kubernetes_cluster_role_binding_v1.tmc_install,
    kubernetes_service_account_v1.tmc_install,
    kubernetes_cluster_role_v1.tmc_install,
    kubernetes_namespace_v1.tmc_local
  ]
}
