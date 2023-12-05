terraform {
  backend "local" {
    workspace_dir = "../../../../terraform-state/03-vault"
  }
}