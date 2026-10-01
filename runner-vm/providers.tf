terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }


  backend "azurerm" {
    resource_group_name  = "fbarryRG"
    storage_account_name = "stfbarrytfstate"
    container_name       = "tfstate"
    key                  = "runner-vm.tfstate"
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}