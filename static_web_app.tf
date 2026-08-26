resource "azurerm_static_web_app" "frontend" {
  name                = "swa-fbarry-quiz"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = "westeurope"
  sku_tier            = "Free"
  sku_size            = "Free"

  tags = merge(local.common_tags, {
    composant = "frontend"
  })
}