# The default package repository installed by TMC does not work and can not be reconciled, hence
# we need a working package repository to install FluxCD dependencies. We need to enable it cluster
# by cluster since the resource is not supported yet at the cluster group level
resource "tanzu-mission-control_package_repository" "tanzu_standard" {
  name     = "tanzu-standard-repo"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.management_cluster_name
    }
  }

  spec {
    imgpkg_bundle {
      image = "projects.registry.vmware.com/tkg/packages/standard/repo:v2.2.0"
    }
  }

  depends_on = [tanzu-mission-control_tanzu_kubernetes_cluster.cluster]
}

locals {
  git_requires_credentials = var.git_repo_credentials != null
}

# Credentials of the the repositories where Flux Kustomizations are hosted
resource "tanzu-mission-control_repository_credential" "cluster_configuration" {
  count = local.git_requires_credentials ? 1 : 0
  name = "cluster-configuration"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.management_cluster_name
    }
  }

  spec {
    data {

      dynamic "username_password" {
        for_each = var.git_repo_credentials.type == "user_pass" ? [var.git_repo_credentials.user_pass] : []

        content {
          username = username_password.value.username
          password = username_password.value.password
        }
      }

      dynamic "ssh_key" {
        for_each = var.git_repo_credentials.type == "ssh" ? [var.git_repo_credentials.ssh] : []

        content {
          identity    = ssh_key.value.identity
          known_hosts = ssh_key.value.known_hosts
        }
      }
    }
  }
}

resource "tanzu-mission-control_git_repository" "cluster_configuration" {
  name = "cluster-configuration"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.management_cluster_name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.cluster_configuration[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = var.git_branch
    }
  }

  depends_on = [ tanzu-mission-control_repository_credential.cluster_configuration ]
}

resource "tanzu-mission-control_kustomization" "cluster_configuration" {
  name = "cluster-configuration"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.cluster.management_cluster_name
    }
  }

  spec {
    # Path in the Git repository. The folder must contain a kustomization.yaml file
    path     = var.cluster_overlay_path
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.cluster_configuration.name
      namespace = tanzu-mission-control_git_repository.cluster_configuration.namespace_name
    }
  }

  depends_on = [ tanzu-mission-control_git_repository.cluster_configuration ]
}