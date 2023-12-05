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

    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }

    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.83.0"
    }

    azuread = {
      source = "hashicorp/azuread"
      version = "2.46.0"
    }
  }
}