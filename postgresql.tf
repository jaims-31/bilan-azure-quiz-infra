resource "random_password" "postgres_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+"
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "psql-fbarry-quiz"
  resource_group_name    = data.azurerm_resource_group.main.name
  location               = data.azurerm_resource_group.main.location
  version                = "16"
  administrator_login    = "psqladmin"
  administrator_password = random_password.postgres_admin.result
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"

  tags = merge(local.common_tags, {
    composant = "postgresql"
  })
}

resource "azurerm_postgresql_flexible_server_database" "quiz" {
  name      = "azurequiz"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}