terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.11.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.0.2"
    }
  }

  required_version = "~> 1.9.0"

  ## Configuration for storing Terraform state remotely in an Azure storage account
  backend "azurerm" {
    resource_group_name  = "terraform"          # Resource group where the storage account is located
    storage_account_name = "workflowstatefiles" # Azure Storage account for storing the state file
    container_name       = "slackbotstate"      # Blob container where the state file will be stored
    key                  = "terraform.tfstate"  # Name of the Terraform state file
    use_oidc             = true                 # Enable OIDC for authentication with Azure
  }
}

provider "azuread" {
  use_oidc = true
}

provider "azurerm" {
  features {}                              # Enables the use of the AzureRM provider without additional config
  use_oidc                        = true   # OIDC authentication with Azure (useful for GitHub Actions)
  resource_provider_registrations = "none" # Disable automatic resource provider registrations
}

data "azuread_service_principal" "sp" {
  object_id = "fddda90e-aa3d-414c-97a3-b30a56ecbbf3"
}

# Define an Azure Resource Group for organizing resources
resource "azurerm_resource_group" "rg" {
  name     = "slack-bot-rg"  # Name of the resource group
  location = "australiaeast" # Azure region where the resource group is located
}

resource "azurerm_container_registry" "example" {
  name                = "boltslackbotacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

