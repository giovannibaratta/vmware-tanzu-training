locals {
  tkgs_clusters = {
    for cluster in var.tkgs_clusters : "${cluster.namespace}/${cluster.name}" => cluster
  }
}
