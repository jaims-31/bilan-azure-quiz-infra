resource "azurerm_linux_web_app" "backend" {
  name                = "app-fbarry-quiz-backend"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  service_plan_id     = data.azurerm_service_plan.shared.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
        application_stack {
      java_server         = "JAVA"
      java_server_version  = "21"
      java_version          = "21"
    }
  }

  tags = merge(local.common_tags, {
    composant = "backend"
  })
}