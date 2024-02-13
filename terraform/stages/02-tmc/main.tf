resource "tanzu-mission-control_cluster_group" "unassigned" {
  name = "unassigned"
}

resource "tanzu-mission-control_cluster_group" "dev" {
  name = "dev"
}

resource "tanzu-mission-control_cluster_group" "prod" {
  name = "prod"
}

# Register the supervisor. The registration must be completed manually using the
# link provided by the resource.
resource "tanzu-mission-control_management_cluster" "tkgs_supervisor" {
  name = "supervisor-h2o"

  spec {
    cluster_group            = tanzu-mission-control_cluster_group.unassigned.name
    kubernetes_provider_type = "VMWARE_TANZU_KUBERNETES_GRID_SERVICE"
  }
}
