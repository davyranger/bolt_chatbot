terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Specify the Azure provider source and version
      version = ">= 3.7.0"          # Minimum required version of AzureRM provider
    }
  }

  ## Configuration for storing Terraform state remotely in an Azure storage account
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state" # Resource group where the storage account is located
    storage_account_name = "tfgithubactions453335"             # Azure Storage account for storing the state file
    container_name       = "boltslackbotcontainer"             # Blob container where the state file will be stored
    key                  = "terraform.tfstate"                 # Name of the Terraform state file
    use_oidc             = true                                # Enable OIDC for authentication with Azure
  }
}
provider "azurerm" {
  features {}     # Enables the use of the AzureRM provider without additional config
  use_oidc = true # OIDC authentication with Azure (useful for GitHub Actions)
}

data "azurerm_resource_group" "example" {
  name = "slack-bot-rg"
}

data "azurerm_container_registry" "example" {
  name                = "boltslackbotcontainerregistry"
  resource_group_name = "slack-bot-rg"
}

resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  os_type = "Linux"

  container {
    name   = "boltslackbot"
    image  = "boltslackbotcontainerregistry.azurecr.io/slack-bot:latest"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port = 80
    }

    environment_variables = {
      SLACK_BOT_TOKEN = var.slack_bot_token
      SLACK_APP_TOKEN = var.slack_app_token
    }
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_container_group.example.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.example.id

  depends_on = [
    azurerm_container_group.example
  ]
}
