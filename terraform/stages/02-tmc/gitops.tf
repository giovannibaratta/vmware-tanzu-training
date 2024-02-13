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

resource "tanzu-mission-control_repository_credential" "gitops" {
  name = "gitops-repo-credentials"

  scope {
    cluster_group {
      name = tanzu-mission-control_cluster_group.dev.name
    }
  }

  spec {
    data {
      username_password {
        username = var.git_repo_credentials.username
        password = var.git_repo_credentials.password
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
    url                = "https://${var.git_repo_url}/poc/flux"
    secret_ref         = tanzu-mission-control_repository_credential.gitops.name
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
    path     = "tanzu-packages"
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.gitops.name
      namespace = tanzu-mission-control_git_repository.gitops.namespace_name
    }
  }
}
