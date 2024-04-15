locals {
  tap_view_cluster_name = "tap-view"
}

resource "kubernetes_secret_v1" "tap_view_cluster_trusted_ca" {
  metadata {
    name      = "${local.tap_view_cluster_name}-user-trusted-ca-secret"
    namespace = local.tap_cluster_namespace
  }

  data = {
    (local.additional_ca_attribute_name) = base64encode(local.tap_cluster_trusted_ca)
  }

  type = "Opaque"
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "tap_view" {
  name                    = local.tap_view_cluster_name
  management_cluster_name = data.tanzu-mission-control_management_cluster.tkgs_supervisor.name
  # vNS name in which the cluster must be created
  provisioner_name = local.tap_cluster_namespace

  spec {
    cluster_group_name = tanzu-mission-control_cluster_group.dev.name

    topology {
      version           = "v1.26.5+vmware.2-fips.1-tkg.1"
      cluster_class     = "tanzukubernetescluster"
      cluster_variables = jsonencode(local.tap_cluster_variables)

      control_plane {
        replicas = 1

        os_image {
          arch    = "amd64"
          name    = "photon"
          version = "3"
        }
      }

      core_addon {
        provider = "kapp-controller"
        type     = "kapp"
      }

      network {
        pod_cidr_blocks = [
          "172.20.0.0/16",
        ]
        service_cidr_blocks = [
          "10.96.0.0/16",
        ]
      }

      nodepool {
        name = "md-0"

        spec {
          worker_class = "node-pool"
          replicas     = 2

          os_image {
            arch    = "amd64"
            name    = "photon"
            version = "3"
          }
        }
      }
    }
  }

  timeout_policy {
    timeout             = 60
    wait_for_kubeconfig = true
    fail_on_timeout     = true
  }

  depends_on = [kubernetes_secret_v1.tap_view_cluster_trusted_ca]

  lifecycle {
    # TMC inject automatically an additional value in additionalTrustedCAs generating a perma-diff.
    # I still need to find a workaround
    ignore_changes = [spec]
  }
}

resource "tanzu-mission-control_kubernetes_secret" "tap_view_cluster_age_key" {
  name           = "sops-keys"
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.management_cluster_name
    }
  }

  export = false

  spec {
    opaque = {
      "age.agekey" = var.age_secret_key
    }
  }
}

resource "tanzu-mission-control_repository_credential" "tap_view_cluster_repo" {
  count = local.git_requires_credentials ? 1 : 0

  name = "tap-repo"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.management_cluster_name
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

resource "tanzu-mission-control_git_repository" "tap_view_installation" {
  name = "tap-installation"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.management_cluster_name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.tap_view_cluster_repo[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = var.tap_branch
    }
  }

  depends_on = [tanzu-mission-control_repository_credential.tap_view_cluster_repo]
}

resource "tanzu-mission-control_kustomization" "tap_view_cluster" {
  name = "tap-gitops"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_view.management_cluster_name
    }
  }

  spec {
    # Path in the Git repository. The folder must contain a kustomization.yaml file
    path     = "${local.kustomization_base_path}overlays/view"
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.tap_view_installation.name
      namespace = tanzu-mission-control_git_repository.tap_view_installation.namespace_name
    }
  }

  depends_on = [tanzu-mission-control_git_repository.tap_view_installation]
}
