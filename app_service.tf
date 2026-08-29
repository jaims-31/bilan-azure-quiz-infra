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
      java_server_version = "21"
      java_version        = "21"
    }

  }

  app_settings = {
    SPRING_PROFILES_ACTIVE     = "prod"
    SPRING_DATASOURCE_URL      = "jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.quiz.name}"
    SPRING_DATASOURCE_USERNAME = azurerm_postgresql_flexible_server.main.administrator_login
    SPRING_DATASOURCE_PASSWORD = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.postgres_admin_password.versionless_id})"
    REDIS_HOSTNAME             = azurerm_managed_redis.main.hostname
    REDIS_PORT                 = azurerm_managed_redis.main.default_database[0].port
    REDIS_PASSWORD             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.redis_primary_key.versionless_id})"
    REDIS_SSL_ENABLED          = "true"
    STORAGE_ACCOUNT_NAME       = var.storage_account_name
    STORAGE_CONTAINER_NAME     = var.storage_container_name
    BACKEND_API_KEY            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.backend_api_key.versionless_id})"
    APP_CORS_ALLOWED_ORIGINS   = "https://${azurerm_static_web_app.frontend.default_host_name}"
  }



  tags = merge(local.common_tags, {
    composant = "backend"
  })
}

