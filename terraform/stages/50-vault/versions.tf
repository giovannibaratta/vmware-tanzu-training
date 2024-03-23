terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.23.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}
