resource "tanzu-mission-control_cluster_group" "unassigned" {
  name = "unassigned"
}

resource "tanzu-mission-control_cluster_group" "dev" {
  name = "dev"
}

resource "tanzu-mission-control_cluster_group" "prod" {
  name = "prod"
}

data "tanzu-mission-control_management_cluster" "tkgs_supervisor" {
  name   = var.supervisor_name
}
