terraform {
  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3, < 3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6, < 4.0.0"
    }

    vsphere = {
      source = "hashicorp/vsphere"
      version = "~> 2.6, < 3.0.0"
    }
  }
}
