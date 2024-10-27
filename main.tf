terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"   # Specify the Azure provider source and version
      version = ">= 3.7.0"            # Minimum required version of AzureRM provider
    }
  }

  # Configuration for storing Terraform state remotely in an Azure storage account
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"   # Resource group where the storage account is located
    storage_account_name = "tfgithubactions453335"               # Azure Storage account for storing the state file
    container_name       = "boltslackbot"                       # Blob container where the state file will be stored
    key                  = "terraform.tfstate"                   # Name of the Terraform state file
    use_oidc             = true                                  # Enable OIDC for authentication with Azure
  }
}

provider "azurerm" {
  features {}                 # Enables the use of the AzureRM provider without additional config
  use_oidc = true              # OIDC authentication with Azure (useful for GitHub Actions)
}

# Define an Azure Resource Group for organizing resources
resource "azurerm_resource_group" "rg" {
  name     = "slack-bot-rg"         # Name of the resource group
  location = "australiacentral"     # Azure region where the resource group is located
}

resource "azurerm_container_registry" "example" {
  name                = "exampleacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command = "bash push_to_acr.sh"
    environment = {
      SLACK_BOT_TOKEN = var.slack_bot_token
	    SLACK_APP_TOKEN=  var.slack_app_token
    }
  }

  depends_on = [azurerm_container_registry.example]
}

