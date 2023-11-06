terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.5.1"
    }

    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
}