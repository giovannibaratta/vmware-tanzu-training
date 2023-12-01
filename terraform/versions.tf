terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.5.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }

    desec = {
      source = "Valodim/desec"
      version = "0.3.0"
    }

    acme = {
      source = "vancluever/acme"
      version = "2.18.0"
    }

    avi = {
      source = "vmware/avi"
      version = "22.1.5"
    }
  }
}