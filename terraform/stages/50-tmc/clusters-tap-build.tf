locals {
  tap_build_cluster_name = "tap-build"
}

resource "kubernetes_secret_v1" "tap_build_cluster_trusted_ca" {
  metadata {
    name      = "${local.tap_build_cluster_name}-user-trusted-ca-secret"
    namespace = local.tap_cluster_namespace
  }

  data = {
    (local.additional_ca_attribute_name) = base64encode(local.tap_cluster_trusted_ca)
  }

  type = "Opaque"
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "tap_build" {
  name                    = local.tap_build_cluster_name
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
          replicas     = 4

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

  depends_on = [kubernetes_secret_v1.tap_build_cluster_trusted_ca]

  lifecycle {
    # TMC inject automatically an additional value in additionalTrustedCAs generating a perma-diff.
    # I still need to find a workaround
    ignore_changes = [spec]
  }
}

# TAP values file contains sensitive data that are encrypted with a SOPs key. Ideally we would use
# the TMC resource to push the key to all clusters, but for now only dockerconfig secrets are supported.
# hence we have to manually push it. This is a huge limitations because we have to define a Kubernetes
# provider for each cluster, and this operations must be handled manually.
resource "kubernetes_secret_v1" "tap_build_cluster_age_key" {
  provider = kubernetes.tap_build_cluster

  metadata {
    name      = "sops-keys"
    namespace = "tanzu-continuousdelivery-resources"
  }

  data = {
    "age.agekey" = var.age_secret_key
  }

  type = "Opaque"
}

resource "tanzu-mission-control_repository_credential" "tap_build_cluster_repo" {
  count = local.git_requires_credentials ? 1 : 0

  name = "tap-repo"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.management_cluster_name
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

resource "tanzu-mission-control_git_repository" "tap_build_installation" {
  name = "tap-installation"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.management_cluster_name
    }
  }

  spec {
    url                = var.git_repo_url
    secret_ref         = local.git_requires_credentials ? tanzu-mission-control_repository_credential.tap_build_cluster_repo[0].name : null
    interval           = "60s"
    git_implementation = "GO_GIT"
    ref {
      branch = var.tap_branch
    }
  }

  depends_on = [tanzu-mission-control_repository_credential.tap_build_cluster_repo]
}

resource "tanzu-mission-control_kustomization" "tap_build_cluster" {
  name = "tap-gitops"

  # The namespace must exists in the target cluster
  namespace_name = "tanzu-continuousdelivery-resources"

  scope {
    cluster {
      name                    = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.name
      provisioner_name        = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.provisioner_name
      management_cluster_name = tanzu-mission-control_tanzu_kubernetes_cluster.tap_build.management_cluster_name
    }
  }

  spec {
    # Path in the Git repository. The folder must contain a kustomization.yaml file
    path     = "manifests/flux-tap/multi-cluster/overlays/build"
    prune    = true
    interval = "60s"

    source {
      name      = tanzu-mission-control_git_repository.tap_build_installation.name
      namespace = tanzu-mission-control_git_repository.tap_build_installation.namespace_name
    }
  }

  depends_on = [tanzu-mission-control_git_repository.tap_build_installation]
}
