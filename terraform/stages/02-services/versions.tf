terraform {

  required_version = ">= 1.7.4"

  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.8"
    }
  }
}
