terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "~> 1.4.3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}
