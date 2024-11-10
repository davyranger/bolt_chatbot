terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "tfgithubactions453335"
    container_name       = "boltslackbotcontainer"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Resource Group Data Source
data "azurerm_resource_group" "example" {
  name = "slack-bot-rg"
}

# Container Registry Data Source
data "azurerm_container_registry" "example" {
  name                = "boltslackbotcontainerregistry"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_client_config" "current" {}

# Reference existing Azure AD Application
data "azuread_application" "existing_app" {
  display_name = "github-actions-terraform-authenticate" # Replace with your existing app registration ID
}

# Create Service Principal for ACR Pull
resource "azuread_service_principal" "sp" {
  client_id = data.azuread_application.existing_app.client_id
}

# Generate password for Service Principal
resource "random_password" "sp_password" {
  length  = 16
  special = true
}

resource "time_rotating" "example" {
  rotation_days = 7
}
resource "azuread_service_principal_password" "sp_password" {
  service_principal_id = azuread_service_principal.sp.id
  rotate_when_changed = {
    rotation = time_rotating.example.id
  }
}

# Role Assignment for ACR Pull Permission
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azuread_service_principal.sp.id
  scope                = data.azurerm_container_registry.example.id
}

# Store Service Principal Password in Key Vault
resource "azurerm_key_vault" "example" {
  name                = "mykeyvault"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_secret" "sp_password_secret" {
  name         = "slackbot-acr-pull-pwd"
  value        = azuread_service_principal_password.sp_password.value
  key_vault_id = azurerm_key_vault.example.id
}

# Store Service Principal ID in Key Vault
resource "azurerm_key_vault_secret" "sp_id_secret" {
  name         = "slackbot-acr-pull-usr"
  value        = data.azuread_application.existing_app.client_id
  key_vault_id = azurerm_key_vault.example.id
}

# Managed Identity
resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "slackbot-identity"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

# Container Group
resource "azurerm_container_group" "example" {
  name                = "boltslackbotgroup"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  os_type             = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  container {
    name   = "boltslackbot"
    image  = "${data.azurerm_container_registry.example.login_server}/slack-bot:latest"
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
    username = azuread_service_principal.sp.application_id
    password = azuread_service_principal_password.sp_password.value
    server   = data.azurerm_container_registry.example.login_server
  }
}

# Custom Role Definition (If Required)
resource "azurerm_role_definition" "custom_role_definition" {
  name        = "RoleAssignmentContributor"
  scope       = data.azurerm_resource_group.example.id
  description = "Custom role with permissions to manage role assignments"
  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.example.id,
    data.azurerm_container_registry.example.id
  ]
}