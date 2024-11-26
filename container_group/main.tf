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

  # Configuration for storing Terraform state remotely in an Azure storage account

  backend "azurerm" {
    resource_group_name  = "terraform"          # Resource group where the storage account is located
    storage_account_name = "workflowstatefiles" # Azure Storage account for storing the state file
    container_name       = "containerstate"     # Blob container where the state file will be stored
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

data "azurerm_container_registry" "example" {
  name                = "boltslackbotacr"
  resource_group_name = "slack-bot-rg"
}

# Define an Azure Resource Group for organizing resources
resource "azurerm_resource_group" "container_rg" {
  name     = "container-rg"  # Name of the resource group
  location = "australiaeast" # Azure region where the resource group is located
}

# Managed Identity

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "slackbot-identity"
  location            = azurerm_resource_group.container_rg.location
  resource_group_name = azurerm_resource_group.container_rg.name
}

# Role Assignments
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.example.id
}

# Container Group
resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  container {
    name   = "boltslackbot"
    image  = "${azurerm_container_registry.example.login_server}/slack-bot:latest"
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

  image_registry_credential {
    user_assigned_identity_id = azurerm_user_assigned_identity.managed_identity.id
    server                    = data.azurerm_container_registry.example.login_server
  }

  depends_on = [
    azurerm_user_assigned_identity.managed_identity
  ]
}

