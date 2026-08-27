resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "id-github-actions-fbarry"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  tags = merge(local.common_tags, {
    composant = "cicd"
  })
}

resource "azurerm_federated_identity_credential" "infra_main_branch" {
  name                      = "github-infra-main"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_actions.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = "https://token.actions.githubusercontent.com"
  subject                   = "repo:jaims-31@172600556/bilan-azure-quiz-infra@1342028630:ref:refs/heads/main"
}

resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github_actions.principal_id
}


resource "azurerm_role_assignment" "github_actions_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id          = azurerm_user_assigned_identity.github_actions.principal_id
}