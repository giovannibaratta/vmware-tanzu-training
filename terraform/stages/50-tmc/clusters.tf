module "external_cluster" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/tmc-flux-tkgs-cluster?ref=tmc-flux-tkgs-cluster-v0.0.1&depth=1"

  cluster_name      = "site-a-external"
  cluster_namespace = "can-you-see-me"
  managed_by        = tanzu-mission-control_management_cluster.tkgs_supervisor.name
  cluster_group     = tanzu-mission-control_cluster_group.dev.name

  vm_class           = "best-effort-large"
  storage_class_name = "vc01cl01-t0compute"

  cluster_additional_trusted_cas = var.clusters_additional_trusted_cas
  git_repo_url                   = var.git_repo_url
  git_repo_credentials           = var.git_repo_credentials
  cluster_overlay_path           = "${var.gitops_repo_cluster_root_folder}/overlays/external/site-a"
}
