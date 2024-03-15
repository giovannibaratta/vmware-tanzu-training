terraform {

  required_version = ">= 1.7.4"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.7.0"
    }

    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.8"
    }
  }
}
