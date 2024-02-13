locals {

  external_cluster_name      = "external"
  external_cluster_namespace = "can-you-see-me"

  external_cluster_secret_ca_attribute_name = "trusted-ca"
  external_cluster_variables = {
    "controlPlaneCertificateRotation" : {
      "activate" : true,
      "daysBefore" : 30
    },
    "defaultStorageClass" : "vc01cl01-t0compute",
    "defaultVolumeSnapshotClass" : "vc01cl01-t0compute",
    "storageClass" : "vc01cl01-t0compute",
    "storageClasses" : [
      "vc01cl01-t0compute"
    ],
    "vmClass" : "best-effort-large",
    "trust" : {
      additionalTrustedCAs : [
        {
          "name" : local.external_cluster_secret_ca_attribute_name
        }
      ]
    }
  }

  external_cluster_trusted_ca = var.clusters_additional_trusted_cas != null ? var.clusters_additional_trusted_cas : ""
}

resource "kubernetes_secret_v1" "external_cluster_trusted_ca" {
  metadata {
    name      = "${local.external_cluster_name}-user-trusted-ca-secret"
    namespace = local.external_cluster_namespace
  }

  data = {
    (local.external_cluster_secret_ca_attribute_name) = base64encode(local.external_cluster_trusted_ca)
  }

  type = "Opaque"
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "external" {
  name                    = local.external_cluster_name
  management_cluster_name = tanzu-mission-control_management_cluster.tkgs_supervisor.name
  # vNS name in which the cluster must be created
  provisioner_name = local.external_cluster_namespace

  spec {
    cluster_group_name = tanzu-mission-control_cluster_group.dev.name

    topology {
      version           = "v1.26.5+vmware.2-fips.1-tkg.1"
      cluster_class     = "tanzukubernetescluster"
      cluster_variables = jsonencode(local.external_cluster_variables)

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
          replicas     = 3

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
    wait_for_kubeconfig = false
    fail_on_timeout     = true
  }

  depends_on = [kubernetes_secret_v1.external_cluster_trusted_ca]

  lifecycle {
    # TMC inject automatically an additional value in additionalTrustedCAs generating a perma-diff.
    # I still need to find a workaround
    ignore_changes = [ spec ]
  }
}
