locals {
  tap_cluster_namespace        = "tap"
  additional_ca_attribute_name = "trusted-ca"

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
          "storage" : "100G"
        },
        "mountPath" : "/var/lib/containerd",
        "name" : "containerd",
        "storageClass" : "vc01cl01-t0compute"
      },
      {
        "capacity" : {
          "storage" : "100G"
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
          "name" : local.additional_ca_attribute_name
        }
      ]
    }
  }

  tap_cluster_trusted_ca = var.clusters_additional_trusted_cas != null ? var.clusters_additional_trusted_cas : ""
}
