mock_provider "vsphere" {}

run "cloud_config_does_not_contain_ansible_user" {

  variables {
    ansible_playbook = null
  }

  command = apply

  assert {
    condition     = ! contains([for user in yamldecode(local.user_data).users: user.name], "ansible")
    error_message = "cloud config contains the user 'ansible'"
  }
}

run "cloud_config_contains_ansible_related_configurations" {

  variables {
    ansible_playbook = "encoded-playbook"
  }

  command = apply

  assert {
    condition     = contains([for user in yamldecode(local.user_data).users: user.name], "ansible")
    error_message = "cloud config does not contain the user 'ansible'"
  }

  assert {
    condition     = [for file in yamldecode(local.user_data).write_files: file.content if file.path == "/ansible/setup-playbook.yaml"][0] == var.ansible_playbook
    error_message = "cloud config does not contain the user provided playbook"
  }

  assert {
    condition = contains(keys(yamldecode(local.user_data)), "ansible")
    error_message = "cloud config does not contain the configuration to run ansible"
  }
}