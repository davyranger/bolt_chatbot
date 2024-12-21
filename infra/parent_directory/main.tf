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

  required_version = "= 1.9.8"

  # Configuration for storing Terraform state remotely in an Azure storage account

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

# import {
#   id = "/subscriptions/54d76c1b-a9fe-4b89-93cb-2585ce0dacb9/resourceGroups/slack-bot-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/slackbot-identity"
#   to = module.container_group.azurerm_user_assigned_identity.managed_identity
# }