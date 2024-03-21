locals {

  tap_cluster_name      = "tap"
  tap_cluster_namespace = "can-you-see-me"

  tap_cluster_secret_ca_attribute_name = "trusted-ca"
  tap_cluster_variables = {
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
    "nodePoolVolumes" : [
      {
        "capacity" : {
          "storage" : "50G"
        },
        "mountPath" : "/var/lib/containerd",
        "name" : "containerd",
        "storageClass" : "vc01cl01-t0compute"
      },
      {
        "capacity" : {
          "storage" : "40G"
        },
        "mountPath" : "/var/lib/kubelet",
        "name" : "kubelet",
        "storageClass" : "vc01cl01-t0compute"
      }
    ]
    "vmClass" : "best-effort-large",
    "trust" : {
      additionalTrustedCAs : [
        {
          "name" : local.tap_cluster_secret_ca_attribute_name
        }
      ]
    }
  }

  tap_cluster_trusted_ca = var.clusters_additional_trusted_cas != null ? var.clusters_additional_trusted_cas : ""
}

resource "kubernetes_secret_v1" "tap_cluster_trusted_ca" {
  metadata {
    name      = "${local.tap_cluster_name}-user-trusted-ca-secret"
    namespace = local.tap_cluster_namespace
  }

  data = {
    (local.tap_cluster_secret_ca_attribute_name) = base64encode(local.tap_cluster_trusted_ca)
  }

  type = "Opaque"
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "tap" {
  name                    = local.tap_cluster_name
  management_cluster_name = tanzu-mission-control_management_cluster.tkgs_supervisor.name
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

  depends_on = [kubernetes_secret_v1.tap_cluster_trusted_ca]

  lifecycle {
    # TMC inject automatically an additional value in additionalTrustedCAs generating a perma-diff.
    # I still need to find a workaround
    ignore_changes = [spec]
  }
}

