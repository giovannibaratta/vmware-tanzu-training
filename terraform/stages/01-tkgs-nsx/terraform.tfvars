vsphere_user = "administrator@vsphere.local"
vsphere_server = "vc01.h2o-2-22574.h2o.vmware.com"
domain = "h2o-2-22574.h2o.vmware.com"

vcenter_data = {
  cluster_name = "vc01cl01"
  datacenter_name = "vc01"
  datastore_name = "vsanDatastore"
  mgmt_segment_name = "user-workload"
}

vm_authorized_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINRHAworzPSIOJki9Q/LKvUQDQefWiU/8DYJoKZxMD2 bgiovanni@vmware.com"