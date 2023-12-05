terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.5.1"
    }

    desec = {
      source  = "Valodim/desec"
      version = "~> 0.3.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.18.0"
    }
  }
}
