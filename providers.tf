terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.3"

    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "fbarryRG"
    storage_account_name = "stfbarrytfstate"
    container_name       = "tfstate"
    key                  = "bilan-azure-quiz.tfstate"
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true

}
