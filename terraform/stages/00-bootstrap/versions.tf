terraform {

  required_version = ">= 1.7.4"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}
