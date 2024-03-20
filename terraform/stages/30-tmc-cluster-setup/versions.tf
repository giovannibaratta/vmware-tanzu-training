terraform {

  required_version = ">= 1.7.4"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
  }
}
