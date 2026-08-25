resource "azurerm_managed_redis" "main" {
  name                = "redis-fbarry-quiz"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  sku_name            = "Balanced_B0"

  default_database {
    access_keys_authentication_enabled = true
  }

  tags = merge(local.common_tags, {
    composant = "redis"
  })
}