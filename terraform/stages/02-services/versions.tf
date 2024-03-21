terraform {

  required_version = ">= 1.7.4"

  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.8"
    }

    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
