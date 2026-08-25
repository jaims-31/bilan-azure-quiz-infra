data "azurerm_resource_group" "main" {
  name = "fbarryRG"
}

data "azurerm_service_plan" "shared" {
  name                = "plan-npr-prf2026"
  resource_group_name = "rg-shared-prf2026"
}