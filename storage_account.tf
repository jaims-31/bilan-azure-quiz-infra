resource "azurerm_storage_account" "main" {
  name                       = var.storage_account_name
  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = data.azurerm_resource_group.main.location
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  min_tls_version              = "TLS1_2"
  shared_access_key_enabled   = false

  network_rules {
    default_action = "Deny"
    bypass          = ["AzureServices"]
    ip_rules        = split(",", azurerm_linux_web_app.backend.outbound_ip_addresses)
  }

  tags = merge(local.common_tags, {
    composant = "storage"
  })
}

resource "azurerm_storage_container" "quiz_media" {
  name                   = var.storage_container_name
  storage_account_id     = azurerm_storage_account.main.id
  container_access_type  = "private"

  depends_on = [azurerm_role_assignment.current_user_storage_blob_contributor]
}