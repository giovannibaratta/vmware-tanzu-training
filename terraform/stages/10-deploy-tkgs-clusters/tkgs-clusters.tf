module "tkgs_clusters" {
  for_each = local.tkgs_clusters

  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/tkgs-cluster?ref=tkgs-cluster-v0.0.1&depth=1"

  cluster_name            = each.value.name
  cluster_namespace       = each.value.namespace
  control_plane_replicas  = each.value.control_plane_replicas
  worker_node_replicas    = each.value.worker_node_replicas
  supervisor_context_name = var.supervisor_context_name
  desired_state           = "PRESENT"

  tkr           = each.value.tkr
  storage_class = each.value.storage_class
  vm_class      = each.value.vm_class

  additional_ca = var.ca_certificate
}
