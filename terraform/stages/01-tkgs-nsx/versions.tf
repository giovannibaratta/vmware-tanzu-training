terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
  }
}
