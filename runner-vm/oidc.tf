data "azurerm_user_assigned_identity" "github_actions" {
  name                = "id-github-actions-fbarry"
  resource_group_name = var.resource_group_name
}

resource "azurerm_federated_identity_credential" "ansible_runner_config_main_branch" {
  name                      = "github-ansible-runner-config-main"
  user_assigned_identity_id = data.azurerm_user_assigned_identity.github_actions.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:jaims-31@172600556/ansible-runner-config@1399736744:ref:refs/heads/main"
}

output "github_actions_client_id" {
  description = "Client ID de l'identité OIDC (à mettre en variable AZURE_CLIENT_ID du repo Ansible)"
  value       = data.azurerm_user_assigned_identity.github_actions.client_id
}