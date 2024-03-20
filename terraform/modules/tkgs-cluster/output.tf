data "kubernetes_secret_v1" "cluster_admin_kubeconfig" {
  count = local.is_apply_action ? 1 : 0

  metadata {
    name      = "${var.cluster_name}-kubeconfig"
    namespace = var.cluster_namespace
  }

  depends_on = [terraform_data.apply_cluster]
}

output "kubeconfig" {
  sensitive = true
  value = try(yamldecode(data.kubernetes_secret_v1.cluster_admin_kubeconfig.0.data.value), null)
}