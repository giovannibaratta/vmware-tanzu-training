locals {
  # List of clusters in which continuos delivery must be enabled
  gitops_clusters = [
    tanzu-mission-control_tanzu_kubernetes_cluster.external,
    tanzu-mission-control_tanzu_kubernetes_cluster.tap
  ]

  gitops_uid_cluster_map = {
    for cluster in local.gitops_clusters : "${cluster.management_cluster_name}.${cluster.provisioner_name}.${cluster.name}" => cluster
  }
}

# The default package repository installed by TMC does not work and can not be reconciled, hence
# we need a working package repository to install FluxCD dependencies. We need to enable it cluster
# by cluster since the resource is not supported yet at the cluster group level
resource "tanzu-mission-control_package_repository" "tanzu_standard" {
  for_each = local.gitops_uid_cluster_map
  name     = "tanzu-standard-repo"

  scope {
    cluster {
      name                    = each.value.name
      provisioner_name        = each.value.provisioner_name
      management_cluster_name = each.value.management_cluster_name
    }
  }

  spec {
    imgpkg_bundle {
      image = "projects.registry.vmware.com/tkg/packages/standard/repo:v2.2.0"
    }
  }

  depends_on = [tanzu-mission-control_tanzu_kubernetes_cluster.external, tanzu-mission-control_tanzu_kubernetes_cluster.tap]
}

locals {
  git_requires_credentials = var.git_repo_credentials != null
}

# Credentials for the the repositories from which retrieve the configurations of packages that must
# be installed in all clusters in the group DEV
resource "tanzu-mission-control_repository_credential" "package_install_repo" {
  count = local.git_requires_credentials ? 1 : 0
  name = "package-install-repo"

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

resource "tanzu-mission-control_git_repository" "package_install" {
  name = "package-install"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster_group {
      name = tanzu-mission-control_cluster_group.dev.name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.package_install_repo[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = "main"
    }
  }

  depends_on = [ tanzu-mission-control_repository_credential.package_install_repo ]
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
      name      = tanzu-mission-control_git_repository.package_install.name
      namespace = tanzu-mission-control_git_repository.package_install.namespace_name
    }
  }

  depends_on = [ tanzu-mission-control_git_repository.package_install ]
}

## TAP installation

# TAP values file contains sensitive data that are encrypted with a SOPs key. Ideally we would use
# the TMC resource to push the key to all clusters, but for now only dockerconfig secrets are supported.
# hence we have to manually push it. This is a huge limitations because we have to define a Kubernetes
# provider for each cluster, and this operations must be handled manually.
resource "kubernetes_secret_v1" "tap_cluster_age_key" {
  provider = kubernetes.tap_cluster

  metadata {
    name      = "sops-keys"
    namespace = "tanzu-continuousdelivery-resources"
  }

  data = {
    "age.agekey" = var.age_secret_key
  }

  type = "Opaque"
}

resource "tanzu-mission-control_repository_credential" "tap_repo" {
  count = local.git_requires_credentials ? 1 : 0

  name = "tap-repo"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap.management_cluster_name
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

resource "tanzu-mission-control_git_repository" "tap_installation" {
  name = "tap-installation"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap.management_cluster_name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.tap_repo[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = "main"
    }
  }

  depends_on = [ tanzu-mission-control_repository_credential.tap_repo ]
}

resource "tanzu-mission-control_kustomization" "tap" {
  name = "tap-gitops"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap.management_cluster_name
    }
  }

  spec {
    # Path in the Git repository. The folder must contain a kustomization.yaml file
    path     = "manifests/flux-tap"
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.tap_installation.name
      namespace = tanzu-mission-control_git_repository.tap_installation.namespace_name
    }
  }

  depends_on = [ tanzu-mission-control_git_repository.tap_installation ]
}
