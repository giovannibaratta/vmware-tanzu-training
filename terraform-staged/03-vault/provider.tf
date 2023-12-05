provider "vault" {
  address = var.vault_address
  token = var.token
  token_name = "terraform"
}