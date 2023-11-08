packer {
  required_plugins {
    vsphere = {
      version = "1.2.1"
      source  = "github.com/hashicorp/vsphere"
    }

    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "1.1.0"
    }
  }
}
