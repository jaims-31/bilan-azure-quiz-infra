output "github_actions_client_id" {
  description = "Client ID de l'identité GitHub Actions"
  value       = azurerm_user_assigned_identity.github_actions.client_id
}

output "azure_tenant_id" {
  description = "Tenant ID Azure"
  value       = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  description = "Subscription ID Azure"
  value       = data.azurerm_client_config.current.subscription_id
}