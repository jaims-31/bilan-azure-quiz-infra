data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "kv-fbarry-quiz"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization   = true
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7

  tags = merge(local.common_tags, {
    composant = "key-vault"
  })
}