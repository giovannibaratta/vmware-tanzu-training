provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.supervisor_context_name
}
