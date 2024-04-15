locals {
  tap_cluster_namespace        = "tap"
  additional_ca_attribute_name = "trusted-ca"

  tap_cluster_variables = {
    "controlPlaneCertificateRotation" : {
      "activate" : true,
      "daysBefore" : 30
    },
    "defaultStorageClass" : var.cluster_storage_class,
    "defaultVolumeSnapshotClass" : var.cluster_storage_class,
    "storageClass" : var.cluster_storage_class,
    "storageClasses" : [
      var.cluster_storage_class
    ],
    "nodePoolVolumes" : [
      {
        "capacity" : {
          "storage" : "100G"
        },
        "mountPath" : "/var/lib/containerd",
        "name" : "containerd",
        "storageClass" : var.cluster_storage_class
      },
      {
        "capacity" : {
          "storage" : "100G"
        },
        "mountPath" : "/var/lib/kubelet",
        "name" : "kubelet",
        "storageClass" : var.cluster_storage_class
      }
    ]
    "vmClass" : var.cluster_vm_class,
    "trust" : {
      additionalTrustedCAs : [
        {
          "name" : local.additional_ca_attribute_name
        }
      ]
    }
  }

  tap_cluster_trusted_ca = var.clusters_additional_trusted_cas != null ? var.clusters_additional_trusted_cas : ""

  kustomization_base_path = var.gitops_repo_cluster_root_folder != "" ? "${var.gitops_repo_cluster_root_folder}/" : ""
}