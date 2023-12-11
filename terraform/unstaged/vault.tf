module "vault_cluster" {
  source = "./modules/vault"

  domain    = "gkube.it"
  num_nodes = var.vault.num_instances
  vip       = var.vault.vip

  vsphere = {
    resource_pool_id = vsphere_resource_pool.mgmt.id
    datastore_id     = data.vsphere_datastore.datastore.id
    port_group_id    = vsphere_distributed_port_group.mgmt_pg_1.id
    template_id      = data.vsphere_content_library_item.debian_goldenimage.id
  }

  generate_certificates           = true
  certificate_dns_challenge_token = var.desec_token
  register_dns                    = true
  deploy_load_balancer            = true
  avi = {
    cloud_id = data.avi_cloud.vcenter.id
  }
}

# Reference https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-azure-keyvault

resource "azurerm_key_vault" "vault" {
  name                = "hashicorp-vault-${random_id.azure.hex}"
  location            = azurerm_resource_group.vault.location
  resource_group_name = azurerm_resource_group.vault.name

  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name                  = "standard"
  enable_rbac_authorization = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Cloud key that will be used to protect the root key of Hashicorp Vault
resource "azurerm_key_vault_key" "vault_seal" {
  name         = "vault-seal"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]

  depends_on = [azurerm_role_assignment.vault_admin]
}

# Hashicorp Vault needs a service principal if it is not running in Azure. This application
# will provide the service principal (client id + client secret) to access Azure Vault.
resource "azuread_application_registration" "vault" {
  display_name     = "Vault"
  description      = "Hashicorp Vault"
  sign_in_audience = "AzureADMyOrg"
}

# Client Secret used by Hashicorp to authenticate
resource "azuread_application_password" "vault" {
  application_id = azuread_application_registration.vault.id
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

# This resource seems to be necessry to assign roles to the service principal 
# generated by the Azure application
resource "azuread_application_api_access" "vault" {
  application_id = azuread_application_registration.vault.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  role_ids = [
    data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  ]
}

# azuread_application_registration generates but do not expose the service principal. With this
# resource we can access it to reference it later
resource "azuread_service_principal" "vault" {
  client_id    = azuread_application_registration.vault.client_id
  use_existing = true
}

# Assign the necessary permissions to the service pricincipal in order to access the keys
# in the Azure Vault
resource "azurerm_role_assignment" "vault_admin_service_principal" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.vault.object_id
}