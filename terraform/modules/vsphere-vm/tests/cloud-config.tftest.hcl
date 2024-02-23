variables {
  ansible_playbook = "encoded-playbook"
}

mock_provider "vsphere" {}

run "cloud_config_contains_ansible_user" {

  command = apply

  assert {
    condition     = contains([for user in yamldecode(local.user_data).users: user.name], "ansible")
    error_message = "cloud config does not contain the user 'ansible'"
  }
}