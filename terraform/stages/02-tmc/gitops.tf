# The default package repository installed by TMC does not work and can not be reconciled, hence
# we need a working package repository to install FluxCD dependencies
resource "tanzu-mission-control_package_repository" "tanzu_standard" {
  name = "tanzu-standard-repo"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.external.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.external.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.external.management_cluster_name
    }
  }

  spec {
    imgpkg_bundle {
      image = "projects.registry.vmware.com/tkg/packages/standard/repo:v2.2.0"
    }
  }

  depends_on = [tanzu-mission-control_tanzu_kubernetes_cluster.external]
}

locals {
  git_requires_credentials = var.git_repo_credentials != null
}

resource "tanzu-mission-control_repository_credential" "gitops" {
  count = local.git_requires_credentials ? 1 : 0
  name  = "gitops-repo-credentials"

  scope {
    cluster_group {
      name = tanzu-mission-control_cluster_group.dev.name
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

resource "tanzu-mission-control_git_repository" "gitops" {
  name = "gitops"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster_group {
      name = tanzu-mission-control_cluster_group.dev.name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.gitops[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = "main"
    }
  }

  depends_on = [tanzu-mission-control_package_repository.tanzu_standard]
}

resource "tanzu-mission-control_kustomization" "package_installation" {
  name = "package-installation"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster_group {
      name = tanzu-mission-control_cluster_group.dev.name
    }
  }

  spec {
    # Path in the Git repository. The folder must contain a kustomization.yaml file
    path     = var.gitops_repo_root_folder
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.gitops.name
      namespace = tanzu-mission-control_git_repository.gitops.namespace_name
    }
  }
}
