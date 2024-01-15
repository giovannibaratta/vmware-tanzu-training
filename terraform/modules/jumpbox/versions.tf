terraform {
  required_providers {
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
