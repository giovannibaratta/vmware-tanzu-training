source "vsphere-iso" "debian_golden_image" {
  CPUs = 4
  RAM  = 16384

  boot_command = ["<esc>auto preseed/url=https://raw.githubusercontent.com/giovannibaratta/debian-preseed/main/preseed.cfg<enter>"]

  guest_os_type = "other5xLinux64Guest"

  insecure_connection = true
  iso_url            = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.2.0-amd64-DVD-1.iso"
  iso_checksum = "sha256:d969b315de093bc065b4f12ab0dd3f5601b52d67a0c622627c899f1d35834b82"

  network_adapters {
    network = "${var.network}"
    network_card = "vmxnet3"
  }

  storage {
    disk_size             = 32768
    disk_thin_provisioned = true
  }

    ssh_username= "debian"
    ssh_password= "debian"


  vcenter_server = "${var.vcenter_server}"
  username       = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"

  cluster = "${var.cluster}"
  datastore="${var.datastore}"

  vm_name = "debian-goldenimage"
  # There is a bug in v1.21 where the postprocessor expect to find the
  # vm in this specific folder.
  # See https://github.com/hashicorp/packer-plugin-vsphere/pull/312
  folder = "Discovered virtual machine"
  destroy = false
  ip_wait_timeout = "1h"
}

build {
  name    = "debian-golden-image"
  sources = ["source.vsphere-iso.debian_golden_image"]

  post-processors {
    post-processor "vsphere-template" {
      host       = "${var.vcenter_server}"
      insecure   = true
      username   = "${var.vcenter_user}"
      password   = "${var.vcenter_password}"
      datacenter = "dc01"
      folder     = "/templates/os/distro"
    }
  }
}