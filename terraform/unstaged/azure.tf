resource "azurerm_resource_group" "vault" {
  name     = "vault"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "random_id" "azure" {
  byte_length = 4
}

resource "azurerm_role_assignment" "vault_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}