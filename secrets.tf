resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.current_user_kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "redis_primary_key" {
  name         = "redis-primary-access-key"
  value        = azurerm_managed_redis.main.default_database[0].primary_access_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.current_user_kv_secrets_officer]
}