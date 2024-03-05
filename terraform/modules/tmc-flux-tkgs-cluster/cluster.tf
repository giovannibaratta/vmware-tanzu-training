locals {
  # This is an arbitrary name
  cluster_ca_secret_attribute_name = "trusted-ca"

  inject_trusted_cas = var.cluster_additional_trusted_cas != null

  cluster_variables = {
    "controlPlaneCertificateRotation" : {
      "activate" : true,
      "daysBefore" : 30
    },
    "defaultStorageClass" : var.storage_class_name,
    "defaultVolumeSnapshotClass" : var.storage_class_name,
    "storageClass" : var.storage_class_name,
    "storageClasses" : [
      var.storage_class_name
    ],
    "nodePoolVolumes" : [
      {
        "capacity" : {
          "storage" : "50G"
        },
        "mountPath" : "/var/lib/containerd",
        "name" : "containerd",
        "storageClass" : var.storage_class_name
      },
      {
        "capacity" : {
          "storage" : "40G"
        },
        "mountPath" : "/var/lib/kubelet",
        "name" : "kubelet",
        "storageClass" : var.storage_class_name
      }
    ]
    "vmClass" : var.vm_class
  }

  cluster_trust_variables = local.inject_trusted_cas ? {
    "trust" : {
      additionalTrustedCAs : [
        {
          "name" : local.cluster_ca_secret_attribute_name
        }
      ]
    }
  } : {}

  full_cluster_variables = merge(local.cluster_variables, local.cluster_trust_variables)
}

resource "kubernetes_secret_v1" "cluster_trusted_ca" {
  count = local.inject_trusted_cas ? 1 : 0
  metadata {
    name      = "${var.cluster_name}-user-trusted-ca-secret"
    namespace = var.cluster_namespace
  }

  data = {
    (local.cluster_ca_secret_attribute_name) = base64encode(var.cluster_additional_trusted_cas)
  }

  type = "Opaque"
}

resource "tanzu-mission-control_tanzu_kubernetes_cluster" "cluster" {
  name                    = var.cluster_name
  management_cluster_name = var.managed_by
  # vNS name in which the cluster must be created
  provisioner_name = var.cluster_namespace

  spec {
    cluster_group_name = var.cluster_group

    topology {
      version           = "v1.26.5+vmware.2-fips.1-tkg.1"
      cluster_class     = "tanzukubernetescluster"
      cluster_variables = jsonencode(local.full_cluster_variables)

      control_plane {
        replicas = var.control_plane_replicas

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
          replicas     = var.worker_nodes_replicas

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

  depends_on = [kubernetes_secret_v1.cluster_trusted_ca]

  lifecycle {
    # TMC inject automatically an additional value in additionalTrustedCAs generating a perma-diff.
    # I still need to find a workaround
    ignore_changes = [ spec ]
  }
}
