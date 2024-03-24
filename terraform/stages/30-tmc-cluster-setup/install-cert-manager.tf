resource "kubernetes_manifest" "tanzu_repository" {
  manifest = yamldecode(file("${path.module}/files/package-repo-tanzu-standard.yaml"))
}

resource "kubernetes_service_account_v1" "cert_manager_install" {

  metadata {
    name      = "cert-manager-tkg-system-sa"
    namespace = "tkg-system"

    annotations = {
      "packaging.carvel.dev/package"       = "cert-manager-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "cert-manager-tkg-system"
    }
  }
}

resource "kubernetes_cluster_role_v1" "cert_manager_install" {

  metadata {
    name = "cert-manager-tkg-system-cluster-role"

    annotations = {
      "packaging.carvel.dev/package"       = "cert-manager-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "cert-manager-tkg-system"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "cert_manager_install" {

  metadata {
    name = "cert-manager-tkg-system-cluster-rolebinding"

    annotations = {
      "packaging.carvel.dev/package"       = "cert-manager-tkg-system"
      "tkg.tanzu.vmware.com/tanzu-package" = "cert-manager-tkg-system"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.cert_manager_install.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.cert_manager_install.metadata.0.name
    namespace = kubernetes_service_account_v1.cert_manager_install.metadata.0.namespace
  }
}

resource "kubernetes_manifest" "cert_manager_package_install" {

  manifest = yamldecode(file("${path.module}/files/package-install-cert-manager.yaml"))


  depends_on = [
    kubernetes_manifest.tanzu_repository,
    kubernetes_service_account_v1.cert_manager_install,
    kubernetes_cluster_role_v1.cert_manager_install,
    kubernetes_cluster_role_binding_v1.cert_manager_install
  ]
}

resource "terraform_data" "wait_for_cert_manager" {
  # Wait for CRDs availability
  provisioner "local-exec" {
    command    = "kubectl wait -f ${path.module}/files/package-install-cert-manager.yaml --for=condition=ReconcileSucceeded --timeout=10m --kubeconfig=<( echo \"${local.kubeconfig_yaml}\" )"
    interpreter = ["bash", "-c"]
    on_failure = fail
  }

  depends_on = [kubernetes_manifest.cert_manager_package_install]
}

resource "kubernetes_secret_v1" "ca_tls" {
  metadata {
    name      = "self-signed-root-ca-tls"
    namespace = "cert-manager"
  }

  data = {
    "tls.crt" = var.ca_certificate
    "tls.key" = var.ca_private_key
  }

  type = "kubernetes.io/tls"

  # We need to wait for the namespace to be available
  depends_on = [terraform_data.wait_for_cert_manager]
}

resource "terraform_data" "cluster_issuer" {

  input = {
    kubeconfig = local.kubeconfig_yaml
  }

  # Apply the manifest
  provisioner "local-exec" {
    command    = "kubectl apply -f ${path.module}/files/cert-manager-issuer.yaml --kubeconfig=<( echo '${self.input.kubeconfig}' )"
    interpreter = ["bash", "-c"]
    on_failure = fail
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete -f ${path.module}/files/cert-manager-issuer.yaml --kubeconfig=<( echo '${self.input.kubeconfig}' )"
    interpreter = ["bash", "-c"]
    on_failure = continue
  }

  depends_on = [kubernetes_secret_v1.ca_tls]
}
